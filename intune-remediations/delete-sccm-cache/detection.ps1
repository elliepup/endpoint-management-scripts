# File: delete-sccm-cache.ps1
# Description: This is the detection logic for the delete-sccm-cache Intune remediation.
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

# get SCCM cache
$sccmCache = Get-SCCMCache -SCCMCachePath $sccmCachePath

# if SCCM cache is empty, exit 0; else, exit 1 to trigger remediation
if ($sccmCache) {
    Write-Host "SCCM cache is not empty. Remediation required."
    exit 1
}
else {
    Write-Host "SCCM cache is empty. No remediation required."
    exit 0
}