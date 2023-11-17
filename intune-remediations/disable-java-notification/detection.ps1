# File: detection.ps1
# Description: This script is used to detect if the java notification feature is enabled in the registry. Ideally, we want this disabled.
# Author: Nicholas Tabb
# Date: 11/17/2023
# Version: 1.0 - Initial Release

# registry key to check
$regKey = "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy"
$regValue = "EnableJavaUpdate"
$desiredValue = 0

# if the regkey property is equal to desired value, remediation is not applicable; exit 0; else, exit 1. also, if the regkey does not exist, remediation is not applicable; exit 0
if ((Get-ItemProperty -Path $regKey -Name $regValue).$regValue -eq $desiredValue) {
    Write-Host "Device is already in the desired state. Remediation is not applicable to this device."
    exit 0
} elseif ($null -eq (Get-ItemProperty -Path $regKey -Name $regValue).$regValue) {
    Write-Host "Device is already in the desired state. Remediation is not applicable to this device."
    exit 0
} else {
    Write-Host "Device is not in the desired state. Remediation is applicable to this device."
    exit 1
}