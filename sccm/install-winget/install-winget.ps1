# File: install-winget.ps1
# Description: This script is used to install winget in the task sequence.
# Author: Nicholas Tabb
# Date: 12/5/2023
# Version: 1.0 - Initial Release

# ---- Modify the following to suit your needs given your environment ---- #
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.7.3172-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$version = "1.22.3172.0" # <-- can be retrieved from Get-AppxPackage cmdlet: Get-AppxPackage | Where-Object {$_.Name -eq "Microsoft.DesktopAppInstaller"}
# ------------------------------------------------------------------------ #

# acquire dependencies
$vclibsx64URL = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$uixamlURL = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0"

# TODO - figure out if dependencies are even necessary

function Get-CurrentVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        $currentVersion = (Get-AppxPackage | Where-Object { $_.Name -eq $PackageName }).Version
        return $currentVersion
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    }
}

function Install-Winget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WingetUrl,
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    try {
        # download winget
        $wingetInstaller = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest -Uri $WingetUrl -OutFile $wingetInstaller

        # install winget; testing with dism instead with region switch to see if it prevents winget from uninstalling itself post-image
        
        Dism.exe /Online /Add-ProvisionedAppxPackage /PackagePath:$wingetInstaller /SkipLicense /Region:"All" /LogPath:"$env:TEMP\winget.log"

        # verify winget version
        Start-Sleep -Seconds 5
        $wingetVersion = (Get-AppxPackage | Where-Object { $_.Name -eq "Microsoft.DesktopAppInstaller" }).Version
        if ($wingetVersion -eq $Version) {
            Write-Host "Winget version $wingetVersion installed successfully"
        }
        else {
            Write-Host "Error: Winget version $wingetVersion installed, but $Version was expected"
            exit 1
        }
    }
    catch {
        Write-Host "Error: $_"
        exit 1
    
    }
}

# if winget is not installed or is not the correct version, install it
$currentVersion = Get-CurrentVersion -PackageName "Microsoft.DesktopAppInstaller"
if ($currentVersion -ne $version) {
    Write-Host "Winget version $currentVersion installed, remediation required"
    Install-Winget -WingetUrl $wingetUrl -Version $version
    exit 0
}
else {
    Write-Host "Winget version $currentVersion installed, remediation not required"
    exit 1
}