<#
.SYNOPSIS
Detects if the classic Teams application is installed.
.DESCRIPTION
Detects if the classic Teams application is installed. The script checks for the existence of the Teams executable. If the executable is found, the script will exit with a 
status of 1. If the executable is not found, the script will exit with a status of 0.
.EXAMPLE
.\detection.ps1
Searches for the classic Teams application.
.NOTES
File Name      : detection.ps1
Author         : Nicholas Tabb
Date           : 09/06/2024
Context        : User (Interactive)
#>

$requireNewTeams = $true # Set to $true if you want to check for the new Teams application. Set to $false if you do not want to check for the new Teams application.

function Get-TeamsExecutable {
    <#
    .SYNOPSIS
    Retrieves the path to the Teams executable.
    .DESCRIPTION
    Retrieves the path to the Teams executable. The function returns the path to the Teams executable.
    .EXAMPLE
    Get-TeamsExecutable
    Returns the path to the Teams executable.
    #>
    $teamsPath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Teams\current\Teams.exe"
    return $teamsPath
}

function Confirm-NewTeamsExists {
    <#
    .SYNOPSIS
    Confirms that the new Teams application is installed.
    .DESCRIPTION
    Confirms that the new Teams application is installed by searching for the application name. If the application is not found, the script will exit with a status of 0.
    It is worth mentioning that this will ONLY check for Teams. This is by design.
    .EXAMPLE
    Confirm-NewTeamsExists
    Searches for the new Teams application.
    #>
    $appName = "MSTeams"
    $newTeams = Get-AppxPackage | Where-Object { $_.Name -eq $appName }

    if (-not $newTeams) {
        Write-Host "New Teams not found." -ForegroundColor Green
        exit 0
    }
}

if ($requireNewTeams) {
    Confirm-NewTeamsExists
}

if (Test-Path (Get-TeamsExecutable)) {
    Write-Host "Classic Teams found. Remediation is required." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "Classic Teams not found." -ForegroundColor Green
    exit 0
}