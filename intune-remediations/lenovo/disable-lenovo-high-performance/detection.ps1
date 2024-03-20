# File: detection.ps1
# Description: This script is used to detect if the laptop is in high performance mode in "BIOS". We want this disabled because it causes the device to use 
# significantly more power than necessary and run hotter and louder than necessary. To be used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 3/20/2024
# Version: 1.0 - Initial Release

# --------------------------- Modify As Necessary ------------------------------- #
$properties = @(
    "AdaptiveThermalManagementAC
    AdaptiveThermalManagementBattery"
)
$desiredState = "Balanced"
# ------------------------------------------------------------------------------- #

function Get-LenovoBiosSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Property
    )

    $getBiosSetting = Get-WmiObject -Class Lenovo_BiosSetting -Namespace root\wmi
    $biosSetting = $getBiosSetting | Where-Object { $_.CurrentSetting -like "$property,*" }

    return $biosSetting
}