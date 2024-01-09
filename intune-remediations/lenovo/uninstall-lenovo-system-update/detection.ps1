# File: detection.ps1
# Description: This checks for the presence of Lenovo System Update. To be used in conjunction with uninstall-lenovo-system-update/remediation.ps1.
# Author: Nicholas Tabb
# Date: 01/09/2023
# Version: 1.0 - Initial Release

# get uninstall string from registry
$displayName = "Lenovo System Update"
function Get-UninstallString { 
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    try {
        $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -eq $DisplayName }).UninstallString
        return $uninstallString
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

$uninstallString = Get-UninstallString -DisplayName $displayName
# if uninstall string is not null, exit 1 indicating remediation is applicable

if ($uninstallString) {
    Write-Host "Lenovo System Update is installed. Remediation is applicable."
    exit 1
}

# if uninstall string is null, exit 0 indicating remediation is not applicable
Write-Host "Lenovo System Update is not installed. Remediation is not applicable."
exit 0
