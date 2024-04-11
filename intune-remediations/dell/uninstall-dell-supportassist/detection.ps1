# File: uninstall-anyconnect/remedition.ps1
# Description: This script uninstalls the Cisco AnyConnect VPN client from the device.
# Author: Nicholas Tabb
# Date: 02/22/2024
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

# if the uninstall string is found, exit 1 to indicate that remediation is required
foreach ($applicationName in $applicationNames) {
    $uninstallString = Get-UninstallString -softwareName $applicationName

    if ($uninstallString) {
        Write-Host "$applicationName is installed. Remediation is required."
        exit 1
    }
}

# if the uninstall string is not found, exit 0 to indicate that no remediation is required
Write-Host "Dell SupportAssist is not installed. No remediation is required."
exit 0