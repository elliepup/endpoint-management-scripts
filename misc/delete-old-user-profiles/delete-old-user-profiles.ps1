# File: detect-winget.ps1
# Description: This script is used to delete user profiles older than x days.
# Author: Nicholas Tabb
# Date: 12/20/2023
# Version: 1.0 - Initial Release

# ---- Modify the following as necessary ---- #
$days = 30 # <--- maximum age of user profile in days
$excludedUsers = @("Administrator", "Public", "Default", "coy-it")
$createScheduledTask = $true # <--- create scheduled task to run this script daily
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

# create scheduled task
function Add-ScheduledTask {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    # if scheduled task already exists, return
    $taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -eq $TaskName }
    if ($taskExists) {
        Write-Host "Scheduled task $TaskName already exists"
        return
    } 

    # create scheduled task
    # run with highest privileges, run whether user is logged on or not, do not store password, run daily at 12:00pm
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
    $trigger = New-ScheduledTaskTrigger -Daily -At "12:00pm"
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal
}

# create local copy of script
$scriptPath = "C:\Windows\Temp\delete-old-user-profiles.ps1"
Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force

# create scheduled task
if ($createScheduledTask) {
    Add-ScheduledTask -TaskName "Delete Old User Profiles" -ScriptPath $scriptPath
}

# get old profiles
$oldProfiles = Get-OldProfiles -Days $days -ExcludedUsers $excludedUsers

# if no old profiles, exit
if ($oldProfiles.Count -eq 0) {
    Write-Host "No old profiles found"
    exit 0
}

# remove old profiles
Remove-OldProfiles -OldProfiles $oldProfiles