# File: detection.ps1
# Description: This script is used to detect if the laptop is in high performance mode in "BIOS". We want this disabled because it causes the device to use 
# significantly more power than necessary and run hotter and louder than necessary. To be used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 3/20/2024
# Version: 1.0 - Initial Release

# --------------------------- Modify As Necessary ------------------------------- #
$properties = @(
    "AdaptiveThermalManagementAC", # specify the BIOS property for Adaptive Thermal Management when on AC power
    "AdaptiveThermalManagementBattery" # specify the BIOS property for Adaptive Thermal Management when on battery power
)
$desiredState = "Balanced" # specify the desired state for the BIOS property
# ------------------------------------------------------------------------------- #


# function to get Lenovo BIOS settings based on specified properties
function Get-LenovoBiosSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Property
    )

    begin {
        $getBiosSetting = Get-WmiObject -Class Lenovo_BiosSetting -Namespace root\wmi
        $results = @()
    }

    process {
        # filter the BIOS settings based on the specified property
        $results += $getBiosSetting | Where-Object { $_.CurrentSetting -like "$Property,*" }
    }

    end {
        return $results
    }

}

# if device is not lenovo, exit 0 to indicate that the device will not be remediated
if (-not (Get-WmiObject -Class Win32_ComputerSystem | Where-Object { $_.Manufacturer -like "Lenovo*" })) {
    Write-Host "Device is not a Lenovo. Remediation is not applicable."
    exit 0
}

$properties | Get-LenovoBiosSetting | ForEach-Object {
    # split the string on the comma and get the second element
    $currentSetting = $_.CurrentSetting.Split(",")[1]
    
    # if the current setting is not equal to the desired state, exit 1
    if ($currentSetting -ne $desiredState) {
        Write-Host "Computer is not in desired state. `nProperty: $($_.CurrentSetting.Split(",")[0]) `nCurrent State: $currentSetting `nDesired State: $desiredState"
        exit 1
    }
}

exit 1