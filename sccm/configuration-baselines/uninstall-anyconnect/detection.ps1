# File: uninstall-anyconnect/detection.ps1
# Description: This script detects if the Cisco AnyConnect VPN client is installed on the device.
# Author: Nicholas Tabb
# Date: 02/22/2024
# Version: 1.0

# first time writing making a configuration baseline so this may not work lol
# we will be using boolean detection method

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

    foreach ($registryPath in $registryPaths) {
        $uninstallString = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -eq $softwareName } | Select-Object -ExpandProperty UninstallString

        if ($uninstallString) {
            return $uninstallString
        }
    }

    return $null
}

# get the uninstall string for the Cisco AnyConnect VPN client
$uninstallString = Get-UninstallString -softwareName "Cisco AnyConnect Secure Mobility Client"

# if the uninstall string is not null, the Cisco AnyConnect VPN client is installed
if ($uninstallString) {
    return $true
} else {
    return $false
}