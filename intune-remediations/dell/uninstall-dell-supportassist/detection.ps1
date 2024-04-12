# File: uninstall-dell-supportassist/detection.ps1
# Description: This script checks if Dell SupportAssist is installed on the device.
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
        $uninstallStrings += Get-ItemProperty -Path $registryPaths | 
        Where-Object { $softwareName -contains $_.DisplayName } | 
        Select-Object -ExpandProperty UninstallString
    }

    end {
        return $uninstallStrings
    }
}

$uninstallString = $applicationNames | Get-UninstallString
if ($uninstallString) {
    Write-Host "Dell SupportAssist is installed. Remediation is required." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Dell SupportAssist is not installed. Remediation is not applicable." -ForegroundColor Green
}