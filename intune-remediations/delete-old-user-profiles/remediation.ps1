# File: detection.ps1
# Description: This is the remediation logic for the delete-user-profiles Intune remediation.
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

function Remove-OldProfiles {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$OldProfiles
    )

    foreach ($profile in $OldProfiles) {
        try {
            $fullProfileName = "C:\Users\$($profile)"
            Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -eq $fullProfileName } | Remove-CimInstance
        }
        catch {
            Write-Host "Error: $_"
            exit 1
        }
    }
}

# get old profiles
$oldProfiles = Get-OldProfiles -Days $days -ExcludedUsers $excludedUsers

# if old profiles exist, remove them
if ($oldProfiles) {
    # remove old profiles
    Remove-OldProfiles -OldProfiles $oldProfiles
    Write-Host "Old profiles removed."
} else {
    Write-Host "No old profiles exist. No remediation required."
}