# File: remediation.ps1
# Description: This script disables hibernation. This script should be used in conjunction with detection.ps1.
# Author: Nicholas Tabb
# Date: 01/22/2023
# Version: 1.0 - Initial Release

# get the current hibernation status
function Get-HibernationStatus {
    $registryKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'
    $attribute = 'HibernateEnabled'

    $hibernationStatus = (Get-ItemProperty -Path $registryKey -Name $attribute).$attribute
    return $hibernationStatus
}

# get the current hibernation status
$hibernationStatus = Get-HibernationStatus

# if hibernation is enabled, disable it
if ($hibernationStatus) {
    Write-Host "Hibernation is enabled. Disabling hibernation."
    powercfg.exe /hibernate off
    exit 1
} else {
    Write-Host "Hibernation is disabled. No remediation is required."
    exit 0
}