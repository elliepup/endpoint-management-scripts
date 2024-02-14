# File: detection.ps1
# Description: This script is used to detect if the user presence sensing feature is enabled in the bios. We want this disabled
#               because it causes issues with the device going to sleep even when the device is in use. To be used in conjunction
#               with the remediation script.
# Author: Nicholas Tabb
# Date: 11/16/2023
# Version: 1.1 - Added faulty BIOS version detection

# property to check for
$property = "UserPresenceSensing"
$desiredValue = "Disable"
# due to a bug made by lenovo in one of the generations of their devices, the value may be inverted; this is the model that is affected. the rest are not (as far as we know)
$faultyModel = "21HES16Q00"
$faultyBiosVersions = @("N3QET37W (1.37 )", "N3QET38W (1.38 )", "N3QET39W (1.39 )", "N3QET40W (1.40 )")
# get the model of the device
$model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$biosVersion = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion

# app we need to check for. this is typically installed by lenovo system update and causes issues with device locking
# will check registry and uninstall if found
$faultyAppName = "Elliptic Virtual Lock Sensor"

function Get-LenovoBiosSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Property
    )

    # if make is not lenovo, return null
    if ((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer -ne "LENOVO") {
        return $null
    }

    $getBiosSetting = Get-WmiObject -Class Lenovo_BiosSetting -Namespace root\wmi
    $biosSetting = $getBiosSetting | Where-Object { $_.CurrentSetting -like "$property,*" }

    return $biosSetting
}

# check if the app is installed. if it is, remediation is applicable; exit 1
function Get-SensorApp {
    # get registry key where the display name contains the faulty app name
    $sensorApp = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*$faultyAppName*" }
    return $sensorApp
}

$lenovoBiosSetting = Get-LenovoBiosSetting -Property $property
# if value is null, remediation is not applicable because the device is not a lenovo device; exit 0
if ($null -eq $lenovoBiosSetting) {
    Write-Host "Remediation is not applicable to this device."
    exit 0
}

# if the model is the faulty model, alter the desired value
if ($model -eq $faultyModel -and $faultyBiosVersions -contains $biosVersion) {
    $desiredValue = "Enable"
    Write-Host "Faulty model detected. Desired value has been altered to $desiredValue."
}

$lenovoBiosSettingValue = $lenovoBiosSetting.CurrentSetting.Split(",")[1]

# these checks could've been combined, but I wanted to be verbose and provide more information in the logs
# if the app is installed, remediation is applicable; exit 1
$sensorApp = Get-SensorApp
if ($null -ne $sensorApp) {
    Write-Host "Faulty app detected. Remediation is applicable to this device."
    exit 1
} else {
    Write-Host "Faulty app not detected. Remediation may not be applicable to this device."
}

# if the value is not the desired value, remediation is applicable; exit 1
if ($lenovoBiosSettingValue -ne $desiredValue) {
    Write-Host "Device is not in the desired state. Remediation is applicable to this device."
    exit 1
} else {
    Write-Host "Device is already in the desired state. Remediation is not applicable to this device."
    exit 0
}

exit 0