<#
.SYNOPSIS
Detects if the Teams Machine-Wide Installer is installed.
.DESCRIPTION
Detects if the Teams Machine-Wide Installer is installed by searching the registry for the application name. If the application is found, remediation is required.
This will be performed by the remediation script and is to be used in an Intune remediation.
.EXAMPLE
.\detection.ps1
Searches the registry for the Teams Machine-Wide Installer application.
.NOTES
File Name      : detection.ps1
Author         : Nicholas Tabb
Date           : 09/06/2024
Context        : Computer (System)
#>

$requireNewTeams = $true # Set to $true to check for the existence of new Teams. This means that remediation will not be required if new Teams is not present.
$applicationName = "Teams Machine-Wide Installer"


# ----- do not modify below this line (unless you know what you are doing) ----- #
function Get-RegistryKey {
    <#
    .SYNOPSIS
    Retrieves the registry key for the specified application.
    .DESCRIPTION
    Retrieves the registry key for the specified application. The function searches the registry hives for the application name.
    .PARAMETER applicationName
    The name of the application to search for.
    .EXAMPLE
    Get-RegistryKey -applicationName "Teams Machine-Wide Installer"
    Searches the registry for the Teams Machine-Wide Installer application.
    #>
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$applicationName
    )

    begin {
        $hives = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", 
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
        $keys = @()
    }   

    process {
        foreach ($hive in $hives) {
            $keys += Get-ItemProperty $hive | Where-Object { $_.DisplayName -Like "$applicationName" }
        }
    }

    end {
        return $keys
    }
}

function Confirm-NewTeamsExists {
    <#
    .SYNOPSIS
    Confirms that the new Teams application is installed.
    .DESCRIPTION
    Confirms that the new Teams application is installed by searching for the application name. If the application is not found, the script will exit with a status of 0.
    .EXAMPLE
    Confirm-NewTeamsExists
    Searches for the new Teams application.
    #>
    $appName = "MSTeams"
    $newTeams = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $appName }

    if (-not $newTeams) {
        Write-Host "New Teams not found." -ForegroundColor Green
        exit 0
    }
}


if ($requireNewTeams) {
    Confirm-NewTeamsExists
}

if ($applicationName | Get-RegistryKey) {
    Write-Host "$applicationName found. Remediation is required." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "$applicationName not found." -ForegroundColor Green
    exit 0
}
