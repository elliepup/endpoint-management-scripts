# File: detection.ps1
# Description: This script detects if hibernation is enabled.
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

# if hibernation is enabled, remediation is required; exit 1
if (Get-HibernationStatus) {
    Write-Host "Hibernation is enabled. Remediation is required."
    exit 1
} else {
    Write-Host "Hibernation is disabled. No remediation is required."
    exit 0
}