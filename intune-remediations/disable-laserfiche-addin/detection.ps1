# File: detection.ps1
# Description: This script is used to detect if Laserfiche Office Plugin is enabled on the device. To be used in conjunction with the remediation script.
#              Getting disabled because of a bug in the plugin that prevents apps from saving files on network shares.
# Author: Nicholas Tabb
# Date: 11/21/2023
# Version: 1.0 - Initial Release

$keys = @(
    "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\Laserfiche.OfficePlugin.Launcher", 
    "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\Laserfiche.OfficePlugin.Launcher", 
    "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Word\Addins\Laserfiche.OfficePlugin.Launcher"
    )

$property = "LoadBehavior"
$idealValue = 0

# if either of them do not exist or value is not $value, exit 1
foreach ($key in $keys) {
    if (!(Test-Path -Path $key)) {
        Write-Host "Key $key does not exist, requires remediation"
        exit 1
    }
    $keyValue = Get-ItemProperty -Path $key -Name $property | Select-Object -ExpandProperty $property
    if ($keyValue -ne $idealValue) {
        Write-Host "Key $key on property $property does not have value $idealValue. Current value is $keyValue, requires remediation"
        exit 1
    }
}

Write-Host "All keys have value $idealValue, no remediation required"
exit 0