# File: uninstall-acrobat.ps1
# Description: This script will be used to detect if any free/unlicensed versions of Adobe Acrobat are installed. 
# It then uninstalls the application.
# Author: Nicholas Tabb
# Date: 02/14/2024
# Version: 1.0 - Initial Release

# function to get the installed version of adobe acrobat; check for literally anything with "Adobe Acrobat" in the name
# check both 32 and 64 bit registry keys
function Get-AdobeAcrobat {
    $adobeAcrobat32 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Adobe Acrobat*" }
    $adobeAcrobat64 = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Adobe Acrobat*" }

    # if both are null, return null; else return the install directory
    if ($null -eq $adobeAcrobat32 -and $null -eq $adobeAcrobat64) {
        return $null
    }
    else {
        return $adobeAcrobat32, $adobeAcrobat64
    }
}

# function to uninstall adobe acrobat
function Remove-AdobeAcrobat {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$uninstallString
    )

    begin {
        Write-Host "Uninstalling Adobe Acrobat..."
    }

    process {
        # uninstall the application
        # replace /I with /X to uninstall
        $uninstallString = $uninstallString -replace "/I", "/X"
        $uninstallString += " /qn"

        cmd /c $uninstallString
    }

    end {
        # check if the uninstall was successful
        $adobeAcrobat = Get-AdobeAcrobat
        if ($null -eq $adobeAcrobat) {
            Write-Host "Adobe Acrobat has been uninstalled." -ForegroundColor Green
        }
        else {
            Write-Host "Adobe Acrobat was not uninstalled." -ForegroundColor Red
        }
    }


}

Get-AdobeAcrobat | Select-Object -ExpandProperty UninstallString | Remove-AdobeAcrobat