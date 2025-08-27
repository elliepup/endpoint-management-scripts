# File: remedation.ps1
# Description: This script uninstalls Dell Command Update. To be used in conjunction with uninstall-dell-command-update/detection.ps1.
# Author: Nicholas Tabb
# Date: 01/09/2023
# Version: 1.0 - Initial Release

# get uninstall string from registry; can either be 32-bit or 64-bit
$displayName = "Dell Command | Update*"

function Get-UninstallString { 
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    # check both 32-bit and 64-bit registry paths
    try {
        $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like $DisplayName }).UninstallString
        if (-not $uninstallString) {
            $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like $DisplayName }).UninstallString
        }
        return $uninstallString
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

$uninstallString = Get-UninstallString -DisplayName $displayName

# if uninstall string is not null, uninstall Dell Command Update
if ($uninstallString) {
    try {
        $uninstallString = ($uninstallString.Replace("/I", "/X").Split(" "))[1]
        Start-Process -FilePath "msiexec.exe" -ArgumentList "$uninstallString /qn" -Wait
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

# double check that Dell Command Update is uninstalled
$uninstallString = Get-UninstallString -DisplayName $displayName

if ($uninstallString) {
    Write-Host "Dell Command Update is still installed. Remediation failed."
    exit 1
}

Write-Host "Dell Command Update is uninstalled. Remediation succeeded."
exit 0