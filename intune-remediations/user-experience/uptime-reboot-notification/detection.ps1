# File: detection.ps1
# Description: This script detects if the device has been up for more than x days. To be used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 1/26/2024
# Version: 1.0 - Initial Release

# ----------- Modify as needed -------------
# number of days the device can be up before prompting for a reboot
$days = 7
# ------------------------------------------

# get the uptime of the device
$uptime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# get the current time
$currentTime = Get-Date

# get the difference between the current time and the uptime
$uptimeSpan = New-TimeSpan -Start $uptime -End $currentTime

# if the uptime is greater than the number of days, remediation is required; exit 1
if ($uptimeSpan.Days -gt $days) {
    Write-Host "The device has been up for more than $days days. Remediation is required."
    exit 1
} else {
    Write-Host "The device has been up for less than $days days. No remediation is required."
    exit 0
}