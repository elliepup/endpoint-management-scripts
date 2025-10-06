# File: detection.ps1
# Description: This script detects if winget is installed and if it needs to be updated.
# Author: Nicholas Tabb
# Date: 12/8/2023
# Version: 1.0 - Initial Release

# ---- Modify the following to suit your needs given your environment ---- #
$minimumVersion = "1.22.3172.0" # <-- can be retrieved from Get-AppxPackage cmdlet: Get-AppxPackage | Where-Object {$_.Name -eq "Microsoft.DesktopAppInstaller"}
# ------------------------------------------------------------------------ #

function Get-CurrentVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        $currentVersion = (Get-AppxPackage | Where-Object { $_.Name -eq $PackageName }).Version
        return $currentVersion
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

# get current version
$currentVersion = Get-CurrentVersion -PackageName "Microsoft.DesktopAppInstaller"

# if version is less than minimum version, remediation is needed; else do nothing
if ($currentVersion -lt $minimumVersion) {
    Write-Host "Winget version $currentVersion detected; remediation needed"
    exit 1
}
Write-Host "Winget version $currentVersion detected; remediation not needed"
exit 0