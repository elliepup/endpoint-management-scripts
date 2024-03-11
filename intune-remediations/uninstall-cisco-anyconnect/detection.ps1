# File: detection.ps1
# Description: This script checks if the Cisco AnyConnect VPN client is installed on the device.
# Author: Nicholas Tabb
# Date: 3/1/2024
# Version: 1.0 - Initial release

# --------------------------- Modify As Necessary ------------------------------- #
$applicationName = "Cisco AnyConnect Secure Mobility Client"
# ------------------------------------------------------------------------------- #

# check if the Cisco AnyConnect VPN client is installed
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
$uninstallString = Get-UninstallString -softwareName $applicationName

# if the uninstall string is not null, the Cisco AnyConnect VPN client is installed
if ($uninstallString) {
    Write-Host "Cisco AnyConnect VPN client is installed. Remediation is required."
    exit 1
} else {
    Write-Host "Cisco AnyConnect VPN client is not installed. No remediation is required."
    exit 0
}