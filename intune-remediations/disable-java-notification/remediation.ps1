# File: detection.ps1
# Description: This script is used to remediate the java notification feature being enabled in the registry. Ideally, we want this disabled.
# Author: Nicholas Tabb
# Date: 11/17/2023
# Version: 1.0 - Initial Release

# registry key to check
$regKey = "HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy"
$regValue = "EnableJavaUpdate"
$desiredValue = 0

# remediate as necessary
Set-ItemProperty -Path $regKey -Name $regValue -Value $desiredValue -Force

# if the regkey property is equal to desired value, remediation is not applicable; exit 0; else, exit 1. also, if the regkey does not exist, remediation is not applicable; exit 0
if ((Get-ItemProperty -Path $regKey -Name $regValue).$regValue -eq $desiredValue) {
    Write-Host "Remediation was successful."
    exit 0
} elseif ($null -eq (Get-ItemProperty -Path $regKey -Name $regValue).$regValue) {
    Write-Host "Remediation was successful."
    exit 0
} else {
    Write-Host "Remediation was not successful."
    exit 1
}