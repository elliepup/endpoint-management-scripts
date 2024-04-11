# File: uninstall-dell-supportassist/remediation.ps1
# Description: This script uninstalls Dell SupportAssist from the device.
# Author: Nicholas Tabb
# Date: 04/11/2024
# Version: 1.0

# first time writing making a configuration baseline so this may not work lol
# --------------------------- Modify As Necessary ------------------------------- #
$applicationNames = @("Dell SupportAssist", "Dell SupportAssist Remediation", "Dell SupportAssist OS Recovery Plugin for Dell Update")
# ------------------------------------------------------------------------------- #

function Get-UninstallString {
    param (
        [Parameter(Mandatory = $true)]
        [string]$softwareName
    )

    # get the uninstall string from the registry
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    # search for the uninstall string in the registry
    foreach ($registryPath in $registryPaths) {
        $uninstallString = Get-ItemProperty -Path $registryPath | Where-Object { $applicationNames -contains $_.DisplayName } | Select-Object -ExpandProperty UninstallString

        if ($uninstallString) {
            return $uninstallString
        }
    }
}

function Uninstall-Application {
    param (
        [Parameter(Mandatory = $true)]
        [string]$uninstallString
    )

    # replace the /I flag with the /X flag to uninstall the application and append the /qn
    $uninstallString = $uninstallString -replace "/I", "/X" -replace "/i", "/X"
    $uninstallString = "$uninstallString /qn"
    
    # uninstall the application using cmd
    cmd /c $uninstallString
}

# get the uninstall string(s) for the application
foreach ($applicationName in $applicationNames) {
    $uninstallString = Get-UninstallString -softwareName $applicationName

    if ($uninstallString) {
        Write-Host "Uninstalling $applicationName..."
        Uninstall-Application -uninstallString $uninstallString
    }
}