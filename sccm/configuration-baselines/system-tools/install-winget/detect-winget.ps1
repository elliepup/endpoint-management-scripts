# File: detect-winget.ps1
# Description: This script is used to detect winget in the task sequence.
# Author: Nicholas Tabb
# Date: 12/5/2023
# Version: 1.0 - Initial Release

# ---- Modify the following to suit your needs given your environment ---- #
$desiredVersion = "1.22.3172.0" # <-- can be retrieved from Get-AppxPackage cmdlet: Get-AppxPackage | Where-Object {$_.Name -eq "Microsoft.DesktopAppInstaller"}
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

# if same as desired version, write to stdout; else do nothing
if ($currentVersion -eq $desiredVersion) {
    Write-Host "Winget version $currentVersion detected"
}