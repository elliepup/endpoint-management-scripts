# File: detection.ps1
# Description: This script uninstalls Lenovo System Update. To be used in conjunction with uninstall-lenovo-system-update/detection.ps1.
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
# if uninstall string is not null, uninstall Lenovo System Update

if ($uninstallString) {
    try {
        Write-Host "Uninstalling Lenovo System Update..."
        Start-Process -FilePath $uninstallString -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" -Wait
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

# double check that Lenovo System Update is uninstalled
$uninstallString = Get-UninstallString -DisplayName $displayName

if ($uninstallString) {
    Write-Host "Lenovo System Update is still installed. Remediation failed."
    exit 1
} 

Write-Host "Lenovo System Update is uninstalled. Remediation succeeded."
exit 0