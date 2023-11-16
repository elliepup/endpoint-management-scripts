# File: detection.ps1
# Description: This script is used to enable .NET 3.5 on Windows 10 devices. It is used in conjunction with the detection script.
# Author: Nicholas Tabb
# Date: 11/16/2023
# Version: 1.0 - Initial Release

# turn off useWUserver and restart it
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name UseWUServer -Value 0
Restart-Service -Name wuauserv

# install .NET 3.5
try {
    Add-WindowsCapability -Online -Name NetFx3~~~~
} catch {
    Write-Host "Failed to install .NET 3.5"
    Write-Error $_.Exception.Message
    exit 1
}

# turn useWUserver back on and restart it
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name UseWUServer -Value 1
Restart-Service -Name wuauserv

# check if .NET 3.5 was installed successfully
$path = "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.5"

# if the key doesn't exist, .NET 3.5 is not installed; remediation required
if (!(Test-Path $path)) {
    Write-Host ".NET 3.5 not installed, remediation required"
    exit 1
}

# if the key exists, .NET 3.5 is installed; no remediation required
Write-Host ".NET 3.5 installed, no remediation required"
exit 0