# File: delete-sccm-cache-and-distro.ps1
# Description: This script deletes the SCCM cache and distribution folders a single time.
# Author: Nicholas Tabb
# Date: 01/18/2023
# Version: 1.0 - Initial Release

# if not running as admin, exit
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Error: This script must be run as an administrator."
    exit 1
}

# ---- Modify the following as necessary ---- #
$sccmCachePath = "C:\Windows\ccmcache"
$softwareDistributionPath = "C:\Windows\SoftwareDistribution\Download"
$deleteSoftwareDistribution = $true # <--- delete SoftwareDistribution folder
# ------------------------------------------- #

function Remove-SCCMCache {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SCCMCachePath
    )

    try {
        # delete all files and folders in SCCM cache
        Get-ChildItem -Path $SCCMCachePath -Force | Remove-Item -Force -Recurse
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

function Remove-SoftwareDistribution {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SoftwareDistributionPath
    )

    try {
        # delete all files and folders in SoftwareDistribution folder
        Get-ChildItem -Path $SoftwareDistributionPath -Force | Remove-Item -Force -Recurse
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

# delete SCCM cache
Write-Host "Deleting SCCM cache..."
Remove-SCCMCache -SCCMCachePath $sccmCachePath

# delete SoftwareDistribution folder
if ($deleteSoftwareDistribution) {
    Write-Host "Deleting SoftwareDistribution folder..."
    Remove-SoftwareDistribution -SoftwareDistributionPath $softwareDistributionPath
}

Write-Host "Done."