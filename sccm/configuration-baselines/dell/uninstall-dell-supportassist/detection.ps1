# File: uninstall-dell-supportassist/detection.ps1
# Description: This script checks if Dell SupportAssist is installed on the device.
# Author: Nicholas Tabb
# Date: 04/15/2024
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

$registryKeys = $applicationNames | Get-RegistryKey

# if keys are found, write to standard output; else do nothing.
# this is how configuration baselines determine compliance.
if ($registryKeys) {
    Write-Host "Found unwanted applications: $($registryKeys.DisplayName -join ', ')" -ForegroundColor Red
}