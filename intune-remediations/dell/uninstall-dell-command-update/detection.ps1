# File: detection.ps1
# Description: This checks for the presence of Dell Command Update. To be used in conjunction with uninstall-dell-command-update/remediation.ps1.
# Author: Nicholas Tabb
# Date: 01/09/2023
# Version: 1.0 - Initial Release

# get uninstall string from registry; can either be 32-bit or 64-bit
$displayName = "Dell Command | Update For Windows Universal"
function Get-UninstallString { 
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName
    )

    # check both 32-bit and 64-bit registry paths
    try {
        $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -eq $DisplayName }).UninstallString
        if (-not $uninstallString) {
            $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -eq $DisplayName }).UninstallString
        }
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
    Write-Host "Dell Command Update is installed. Remediation is applicable."
    exit 1
}

# if uninstall string is null, exit 0 indicating remediation is not applicable
Write-Host "Dell Command Update is not installed. Remediation is not applicable."
exit 0