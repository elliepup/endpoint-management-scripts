# File: remediation.ps1
# Description: This script checks if the Cisco AnyConnect VPN client is installed on the device. If it is installed, the script will uninstall the software.
# Author: Nicholas Tabb
# Date: 3/1/2024
# Version: 1.0 - Initial release

# --------------------------- Modify As Necessary ------------------------------- #
$applicationName = "Cisco AnyConnect Secure Mobility Client"
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

    foreach ($registryPath in $registryPaths) {
        $uninstallString = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -eq $softwareName } | Select-Object -ExpandProperty UninstallString

        if ($uninstallString) {
            return $uninstallString
        }
    }

    return $null
}

function Uninstall-Application {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$uninstallString
    )

    process {
        # replace the /I with /X to uninstall the software in the event that we've been trolled
        $uninstallString = $uninstallString -replace "/I", "/X"

        # append /qn to the uninstall string to make it silent
        $uninstallString += " /qn"

        # uninstall the software with cmd
        cmd /c $uninstallString
    }
}

# get the uninstall string for the Cisco AnyConnect VPN client and uninstall the software
Get-UninstallString -softwareName $applicationName | Uninstall-Application

# detection script will execute again; no need to check if the software is uninstalled