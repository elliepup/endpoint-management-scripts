# File: detection.ps1
# Description: This script detects if the DCU notification is enabled.
# Author: Nicholas Tabb
# Date: 01/08/2023
# Version: 1.0 - Initial Release

# path to DCU registry key
$property = "ScheduleMode"
$path = "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule"
$desiredValue = "ManualUpdates"

# check if machine is a Dell
$manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
if ($manufacturer -ne "Dell Inc.") {
    Write-Host "This machine is not a Dell. Remediation is not applicable."
    exit 0
}

# if path exists but no property, remediation is applicable
if (Test-Path -Path $path) {
    $propertyExists = Get-ItemProperty -Path $path -Name $property -ErrorAction SilentlyContinue
    if (-not $propertyExists) {
        Write-Host "DCU property does not exist. Remediation is applicable."
        exit 1
    }
}

# if path exists and property exists but value is not desired, remediation is applicable
if (Test-Path -Path $path) {
    $propertyExists = Get-ItemProperty -Path $path -Name $property -ErrorAction SilentlyContinue
    if ($propertyExists) {
        $propertyValue = Get-ItemPropertyValue -Path $path -Name $property
        if ($propertyValue -ne $desiredValue) {
            Write-Host "DCU property value is not desired. Remediation is applicable."
            exit 1
        }
    }
}

# if the value is already set to desired, remediation is not applicable
Write-Host "DCU property value is already set to desired. Remediation is not applicable."
exit 0