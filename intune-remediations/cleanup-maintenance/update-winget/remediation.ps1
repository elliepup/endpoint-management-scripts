# File: detection.ps1
# Description: This script detects if winget is installed and if it needs to be updated.
# Author: Nicholas Tabb
# Date: 12/8/2023
# Version: 1.0 - Initial Release

# ---- Modify the following to suit your needs given your environment ---- #
$wingetURL = "https://github.com/microsoft/winget-cli/releases/download/v1.7.3172-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
# TODO add unc path support at some point
# ------------------------------------------------------------------------ #

function Install-Winget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WingetUrl
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

Install-Winget -WingetUrl $wingetURL