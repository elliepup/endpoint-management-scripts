<#
.SYNOPSIS
Uninstalls Oracle Java applications.
.DESCRIPTION
Uninstalls Oracle Java applications by searching for applications with a name starting with "Java" and a publisher of "Oracle Corporation". This script is designed to be used as 
a remediation script in SCCM Configuration Baselines.
.EXAMPLE
.\remediation.ps1
Uninstalls Oracle Java applications.
.NOTES
File Name      : remediation.ps1
Author         : Nicholas Tabb
Date           : 02/19/2025
Run Context    : System
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
        (-not $Publisher -or $_.Publisher -eq $Publisher) -and
        -not [string]::IsNullOrEmpty($_.UninstallString)
    }

    return $applications
}

function Uninstall-OracleJavaApplication {
    <#
    .SYNOPSIS
    Uninstalls Oracle Java applications.
    .DESCRIPTION
    Uninstalls Oracle Java applications by searching for applications with a name starting with "Java" and a publisher of "Oracle Corporation".
    .PARAMETER Application
    The application object to uninstall. This is the registry object returned by Get-InstalledApplication.
    .EXAMPLE
    $javaApps = Get-InstalledApplication -Name "Java*" -Publisher "Oracle Corporation"
    $javaApps | Uninstall-OracleJavaApplication
    Uninstalls all Oracle Java applications found.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]$Application
    )

    process {
        try {
            Write-Host "Attempting to uninstall $($Application.DisplayName)..." -ForegroundColor Yellow
            
            if ($Application.UninstallString -match "msiexec") {
                # Handle MSI uninstalls
                $msiCode = [regex]::Match($Application.UninstallString, '{[A-Z0-9\-]+}').Value
                if ($msiCode) {
                    $arguments = "/X $msiCode /qn /norestart"
                    Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
                }
                else {
                    throw "Could not find MSI product code"
                }
            }
            else {
                # Handle executable uninstalls
                $uninstallString = $Application.UninstallString
                if ($uninstallString) {
                    $process = Start-Process -FilePath $uninstallString -ArgumentList "/s" -Wait -PassThru -NoNewWindow
                    if ($process.ExitCode -ne 0) {
                        throw "Uninstall process failed with exit code: $($process.ExitCode)"
                    }
                }
                else {
                    throw "No uninstall string found"
                }
            }
            
            Write-Host "Successfully uninstalled $($Application.DisplayName)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to uninstall $($Application.DisplayName): $_" -ForegroundColor Red
        }
    }
}

$javaApps = Get-InstalledApplication -Name "Java*" -Publisher "Oracle Corporation"
$javaApps | Uninstall-OracleJavaApplication
