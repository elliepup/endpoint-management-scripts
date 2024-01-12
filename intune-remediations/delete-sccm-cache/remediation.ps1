# File: remediation.ps1
# Description: This is the remediation logic for the delete-sccm-cache Intune remediation.
# Author: Nicholas Tabb
# Date: 01/12/2023
# Version: 1.0 - Initial Release

# ---- Modify the following as necessary ---- #
$sccmCachePath = "C:\Windows\ccmcache"
# ------------------------------------------- #

function Get-SCCMCache {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SCCMCachePath
    )

    try {
        $sccmCache = Get-ChildItem -Path $SCCMCachePath -Force
        return $sccmCache
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

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

# get SCCM cache
$sccmCache = Get-SCCMCache -SCCMCachePath $sccmCachePath

# if SCCM cache is empty, exit 0; else, delete SCCM cache
if ($sccmCache) {
    Write-Host "SCCM cache is not empty. Deleting SCCM cache."
    Remove-SCCMCache -SCCMCachePath $sccmCachePath
}
else {
    Write-Host "SCCM cache is empty. No remediation required."
}