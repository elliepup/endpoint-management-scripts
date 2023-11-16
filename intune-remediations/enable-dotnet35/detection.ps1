# File: detection.ps1
# Description: This script is used to detect if .NET 3.5 is installed. It is used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 11/16/2023
# Version: 1.0 - Initial Release

$path = "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.5"

# if the key doesn't exist, .NET 3.5 is not installed; remediation required
if (!(Test-Path $path)) {
    Write-Host ".NET 3.5 not installed, remediation required"
    exit 1
}

# if the key exists, .NET 3.5 is installed; no remediation required
Write-Host ".NET 3.5 installed, no remediation required"
exit 0