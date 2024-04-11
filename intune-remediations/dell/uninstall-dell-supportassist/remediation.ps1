# File: uninstall-dell-supportassist/remediation.ps1
# Description: This script uninstalls Dell SupportAssist from the device.
# Author: Nicholas Tabb
# Date: 04/11/2024
# Version: 1.0

# first time writing making a configuration baseline so this may not work lol
# --------------------------- Modify As Necessary ------------------------------- #
$applicationNames = @("Dell SupportAssist", "Dell SupportAssist Remediation", "Dell SupportAssist OS Recovery Plugin for Dell Update")
# ------------------------------------------------------------------------------- #

function Get-UninstallString {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$softwareName
    )

    begin {
        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $uninstallStrings = @()
    }

    process {
        $uninstallStrings += Get-ItemProperty -Path $registryPaths | Where-Object { $softwareName -contains $_.DisplayName } | Select-Object -ExpandProperty UninstallString
    }

    end {
        return $uninstallStrings
    }
}

function Uninstall-Application {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$uninstallString
    )

    process {
        $uninstallString = $uninstallString -replace "/I", "/X"
        $uninstallString = $uninstallString + " /qn"

        cmd /c $uninstallString
    }
}

$applicationNames | Get-UninstallString | Uninstall-Application

# double check if the application is uninstalled
$uninstallString = $applicationNames | Get-UninstallString
if ($uninstallString) {
    Write-Host "Failed to uninstall Dell SupportAssist."
    exit 1
} else {
    Write-Host "Dell SupportAssist has been uninstalled."
}