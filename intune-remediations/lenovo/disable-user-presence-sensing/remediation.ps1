# File: detection.ps1
# Description: This is the remediation script for the User Presence Sensing feature in the bios. We want this disabled because 
#               it causes issues with the device going to sleep even when the device is in use. To be used in conjunction with the
#               detection script.
# Author: Nicholas Tabb
# Date: 11/16/2023
# Version: 1.0 - Initial Release

# property to check for
$property = "UserPresenceSensing"
$desiredValue = "Disable"
# due to a bug made by lenovo in one of the generations of their devices, the value may be inverted; 
#this is the model that is affected. the rest are not (as far as we know)
$faultyModel = "21HES16Q00"
$faultyBiosVersions = @("N3QET37W (1.37 )", "N3QET38W (1.38 )", "N3QET39W (1.39 )")
# get the model of the device
$model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$biosVersion = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion

$faultyAppName = "Elliptic Virtual Lock Sensor"
# double check that the device is a lenovo and that remediation is applicable
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
        $saveBiosSetting.SaveBiosSettings()
    } catch {
        # if an error occurs, exit with code 1
        exit 1
    }
}

# check if the app is installed. if it is, remediation is applicable; exit 1
function Get-SensorApp {
    # get registry key where the display name contains the faulty app name
    $sensorApp = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*$faultyAppName*" }
    return $sensorApp
}

function Uninstall-SensorApp {
    # get the uninstall string from the registry
    $sensorApp = Get-SensorApp

    # replace the /I with /X to uninstall the app
    $guid = $sensorApp.PSChildName
    $argList = @(
        '/X'
        $guid
        '/qn'
    )
    Start-Process msiexec.exe -ArgumentList $argList -Wait
}

$lenovoBiosSetting = Get-LenovoBiosSetting -Property $property

# if value is null, remediation is not applicable; exit 0
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
# if the current value is the desired value, remediation is not applicable; exit 0; else, perform remediation
if ($lenovoBiosSettingValue -eq $desiredValue) {
    Write-Host "Device is already in the desired state, however, the faulty app may still be installed."
} else {
    # perform remediation
    Write-Host "Device is not in the desired state, performing remediation..."
    Set-LenovoBiosSetting -property $property -value $desiredValue
}

# if the app is installed, uninstall it
$sensorApp = Get-SensorApp
if ($null -ne $sensorApp) {
    Write-Host "Faulty app detected. Uninstalling..."
    Uninstall-SensorApp
}

# computer will need to be restarted for changes to take effect, but we will exit 0 anyway to not affect the user
exit 0