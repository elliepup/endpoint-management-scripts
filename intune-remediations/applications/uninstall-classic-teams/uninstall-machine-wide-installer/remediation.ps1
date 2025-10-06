<#
.SYNOPSIS
Uninstalls the Teams Machine-Wide Installer.
.DESCRIPTION
Uninstalls the Teams Machine-Wide Installer by running the uninstall string from the registry key.
.EXAMPLE
.\remediation.ps1
Uninstalls the Teams Machine-Wide Installer.
.NOTES
File Name      : remediation.ps1
Author         : Nicholas Tabb
Date           : 09/06/2024
Context        : Computer (System)
#>

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
            $keys += Get-ItemProperty $hive | Where-Object {$_.DisplayName -Like "$applicationName"}
        }
    }

    end {
        return $keys
    }
}

function Uninstall-Application {
    <#
    .SYNOPSIS
    Uninstalls the application.
    .DESCRIPTION
    Uninstalls the application by running the uninstall string from the registry key.
    .PARAMETER registryKey
    The registry key for the application to uninstall.
    .EXAMPLE
    $applicationName | Get-RegistryKey | Uninstall-Application
    Uninstalls the application.
    #>
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.Object]$registryKey
    )

    process {
        
        $uninstallString = $registryKey.UninstallString

        if ($uninstallString -match "msiexec") {
            $uninstallString = $uninstallString -replace "/I", "/X"
            $uninstallString += " /qn"
        }

        & cmd /c $uninstallString

        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($registryKey.DisplayName) uninstalled successfully."
        } else {
            Write-Host "Failed to uninstall the application."
        }
    }
}

$applicationName | Get-RegistryKey | Uninstall-Application