<#
.SYNOPSIS
Tests if Oracle Java is installed.
.DESCRIPTION
Tests if Oracle Java is installed by searching for applications with a name starting with "Java" and a publisher of "Oracle Corporation". This is to be used as a detection script
in an Intune remediation. If Oracle Java is found, the script will exit with a status of 1. If Oracle Java is not found, the script will exit with a status of 0. This is how Intune
determines if the remediation is required.
.EXAMPLE
.\detection.ps1
Tests if Oracle Java is installed.
.NOTES
File Name      : detection.ps1
Author         : Nicholas Tabb
Date           : 02/18/2025
Context        : Computer (System)
#>

function Get-InstalledApplication {
    <#
    .SYNOPSIS
    Get installed applications from the registry.
    .DESCRIPTION
    Get installed applications from the registry based on the provided name and publisher. If no publisher is provided, all applications with the provided name will be returned.
    .PARAMETER Name
    The name of the application to search for.
    .PARAMETER Publisher
    The publisher of the application to search for.
    .EXAMPLE
    Get-InstalledApplication -Name "Java*"
    Searches for all applications with a name starting with "Java".
    .EXAMPLE
    Get-InstalledApplication -Name "Java*" -Publisher "Oracle Corporation"
    Searches for all applications with a name starting with "Java" and a publisher of "Oracle Corporation".    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string]$Publisher
    )

    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $applications = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ -ErrorAction SilentlyContinue
    } | Where-Object { 
        $_.DisplayName -like $Name -and
        (-not $Publisher -or $_.Publisher -eq $Publisher)
    }

    return $applications
}

function Test-OracleJavaInstallation {
    <#
    .SYNOPSIS
    Tests if Oracle Java is installed.
    .DESCRIPTION
    Tests if Oracle Java is installed by searching for applications with a name starting with "Java" and a publisher of "Oracle Corporation".
    .EXAMPLE
    Test-OracleJavaInstallation
    Tests if Oracle Java is installed.
    #>
    [CmdletBinding()]
    param()

    $javaApps = Get-InstalledApplication -Name "Java*" -Publisher "Oracle Corporation"

    if (-not $javaApps) {
        Write-Host "Oracle Java not found." -ForegroundColor Green
        return $false
    }
    
    Write-Host "Oracle Java found." -ForegroundColor Red
    return $true
}

# Exit with appropriate code based on Java installation status
exit ([int](Test-OracleJavaInstallation))
