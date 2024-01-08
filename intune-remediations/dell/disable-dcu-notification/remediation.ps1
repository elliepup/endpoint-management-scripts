# File: remedation.ps1
# Description: This script remediates the DCU notification. It sets the DCU notification to manual updates.
# Author: Nicholas Tabb
# Date: 01/08/2023
# Version: 1.0 - Initial Release

# path to DCU registry key
$property = "ScheduleMode"
$path = "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule"
$desiredValue = "ManualUpdates"

# assuming if running this script, machine is a Dell; not checking again even though all I'd have to do is copy/paste from the detection script

# if path exists but no property, create property and set to desired value
if (Test-Path -Path $path) {
    $propertyExists = Get-ItemProperty -Path $path -Name $property -ErrorAction SilentlyContinue
    if (-not $propertyExists) {
        New-ItemProperty -Path $path -Name $property -Value $desiredValue -PropertyType String | Out-Null
    }
}

# if path exists and property exists but value is not desired, set value to desired
if (Test-Path -Path $path) {
    $propertyExists = Get-ItemProperty -Path $path -Name $property -ErrorAction SilentlyContinue
    if ($propertyExists) {
        $propertyValue = Get-ItemPropertyValue -Path $path -Name $property
        if ($propertyValue -ne $desiredValue) {
            Set-ItemProperty -Path $path -Name $property -Value $desiredValue | Out-Null
        }
    }
}

# double check that the value is already set to desired
$propertyValue = Get-ItemPropertyValue -Path $path -Name $property
if ($propertyValue -eq $desiredValue) {
    Write-Host "DCU property value is set to desired."
    exit 0
}