# File: delete-sccm-cache.ps1
# Description: This script deletes the SCCM cache on a scheduled basis.
# Author: Nicholas Tabb
# Date: 01/10/2023
# Version: 1.0 - Initial Release

# ---- Modify the following as necessary ---- #
$createScheduledTask = $true # <--- create scheduled task to run this script daily
$sccmCachePath = "C:\Windows\ccmcache"
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
        return
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
    $trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -At "10am" -DaysOfWeek Monday
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -User "SYSTEM"
}

# create local copy of script
$scriptPath = "C:\Windows\Temp\delete-sccm-cache.ps1"
Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force

# create scheduled task
if ($createScheduledTask) {
    Add-ScheduledTask -TaskName "Delete SCCM Cache" -ScriptPath $scriptPath
}

# delete SCCM cache
Remove-SCCMCache -SCCMCachePath $sccmCachePath