# File: uninstall-dell-supportassist/remediation.ps1
# Description: This script uninstalls Dell SupportAssist from the device.
# Author: Nicholas Tabb
# Date: 04/11/2024
# Version: 1.0

# --------------------------- Modify As Necessary ------------------------------- #
$applicationNames = @("Dell SupportAssist", "Dell SupportAssist Remediation", "Dell SupportAssist OS Recovery Plugin for Dell Update")
# ------------------------------------------------------------------------------- #

function Get-RegistryKey {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$softwareName
    )

    begin {
        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $registryKeys = @()
    }

    process {
        $registryKeys += Get-ItemProperty -Path $registryPaths | 
        Where-Object { $softwareName -contains $_.DisplayName } | 
        Select-Object DisplayName,UninstallString,QuietUninstallString
    }

    end {
        return $registryKeys
    }
}

function Uninstall-Application {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object[]]$registryKey
    )

    process {
        # if there exists a quiet uninstall string, use it
        if ($registryKey.QuietUninstallString) {
            $uninstallString = $registryKey.QuietUninstallString
        } else {
            $uninstallString = $registryKey.UninstallString -replace '/I', '/X'
            $uninstallString += ' /qn'
        }

        try {
            Start-Process "cmd.exe" -ArgumentList "/c $uninstallString" -Wait -NoNewWindow
        } catch {
            Write-Host "An error occurred while uninstalling the application: $_" -ForegroundColor Red
        }
    }
}



$registryKeys = $applicationNames | Get-RegistryKey
# if there are two registry keys specifically for the os recovery plugin, only keep the one that contains a quiet uninstall string
if (($registryKeys | Where-Object { $_.DisplayName -eq $applicationNames[2] }).Count -eq 2) {
    $registryKeys = $registryKeys | Where-Object { $_.DisplayName -ne $applicationNames[2] -or $_.QuietUninstallString -ne $null }
}

$registryKeys | Uninstall-Application

# check if any of the applications are still installed for logging purposes
$registryKeys = $applicationNames | Get-RegistryKey
if ($registryKeys) {
    Write-Host "Dell SupportAssist is still installed." -ForegroundColor Red
} else {
    Write-Host "Dell SupportAssist has been uninstalled." -ForegroundColor Green
}