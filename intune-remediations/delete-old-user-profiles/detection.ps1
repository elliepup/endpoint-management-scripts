# File: detection.ps1
# Description: This is the detection logic for the delete-user-profiles Intune remediation.
# Author: Nicholas Tabb
# Date: 01/17/2023
# Version: 1.0 - Initial Release

# ---- Modify the following as necessary ---- #
$days = 30 # <--- maximum age of user profile in days
$excludedUsers = @("Administrator", "Public", "Default")
# ------------------------------------------- #

function Get-OldProfiles {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Days,
        [Parameter(Mandatory = $true)]
        [string[]]$ExcludedUsers
    )

    try {
        $oldProfiles = Get-ChildItem -Path "C:\Users" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Days) -and $ExcludedUsers -notcontains $_.Name }
        return $oldProfiles
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

# get old profiles
$oldProfiles = Get-OldProfiles -Days $days -ExcludedUsers $excludedUsers

# if old profiles exist, exit 1 to indicate remediation is required
if ($oldProfiles) {
    Write-Host "Old profiles exist. Remediation required."
    exit 1
} else {
    Write-Host "No old profiles exist. Remediation not required."
    exit 0
}