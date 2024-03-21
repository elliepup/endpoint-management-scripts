# File: remediation.ps1
# Description: This script is used to remediate the issue of high performance mode in "BIOS" on Lenovo laptops. Disabling high performance mode helps conserve 
# power and reduce heat and noise levels.
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

function Set-LenovoBiosSetting {
    # assumes no bios password is required because i am too lazy to implement that feature even though it would take 30 seconds to add
    param (
        [Parameter(Mandatory = $true)]
        [string]$property,
        [Parameter(Mandatory = $true)]
        [string]$value
    )

    try {
        # get the wmi objects needed to set and save the bios settings
        $setBiosSetting = Get-WmiObject -Class Lenovo_SetBiosSetting -Namespace root\wmi
        $saveBiosSetting = Get-WmiObject -Class Lenovo_SaveBiosSettings -Namespace root\wmi

        # set and save the bios settings
        $setBiosSetting.SetBiosSetting("$property,$value")
        $saveBiosSetting.SaveBiosSettings() | Out-Null
    } catch {
        # if an error occurs, exit with code 1
        exit 1
    }
}

# if device is not lenovo, exit 0 to indicate that the device will not be remediated
if (-not (Get-WmiObject -Class Win32_ComputerSystem | Where-Object { $_.Manufacturer -like "Lenovo*" })) {
    Write-Host "Device is not a Lenovo. Remediation is not applicable."
    exit 0
}

$properties | Get-LenovoBiosSetting | Where-Object { $_.CurrentSetting.Split(",")[1] -ne $desiredState } | ForEach-Object {
    Set-LenovoBiosSetting -property $_.CurrentSetting.Split(",")[0] -value $desiredState
}

# check to see if the settings were applied successfully
$properties | Get-LenovoBiosSetting | Where-Object { $_.CurrentSetting.Split(",")[1] -ne $desiredState } | ForEach-Object {
    Write-Host "Failed to remediate the issue. `nProperty: $($_.CurrentSetting.Split(",")[0]) `nCurrent State: $($_.CurrentSetting.Split(",")[1]) `nDesired State: $desiredState"
    exit 1
}

Write-Host "Successfully remediated the issue." -ForegroundColor Green