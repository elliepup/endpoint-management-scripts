# File: detection.ps1
# Description: This script is used to remediate Laserfiche Office Plugin. To be used in conjunction with the detection script.
#              Getting disabled because of a bug in the plugin that prevents apps from saving files on network shares.
# Author: Nicholas Tabb
# Date: 11/29/2023
# Version: 1.0 - Initial Release


$keys = @(
    "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\Laserfiche.OfficePlugin.Launcher", 
"HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\Laserfiche.OfficePlugin.Launcher", 
"HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Word\Addins\Laserfiche.OfficePlugin.Launcher"
)
$property = "LoadBehavior"
$idealValue = 0

# if any of them do not exist or value is not $value, set value to $idealValue. try catch block. exit 1 if any errors, else exit 0
foreach ($key in $keys) {
    if (!(Test-Path -Path $key)) {
        Write-Host "Key $key does not exist, creating key"
        try {
            New-Item -Path $key -Force | Out-Null
        } catch {
            Write-Host "Error creating key $key, remediation failed. May require manual intervention."
            exit 1
        }
    }
    try {
        Set-ItemProperty -Path $key -Name $property -Value $idealValue -Force | Out-Null
        Write-Host "Set value $idealValue on key $key"
    } catch {
        Write-Host "Error setting value $idealValue on key $key, remediation failed. May require manual intervention."
        exit 1
    }
}

Write-Host "All keys have value $idealValue, no remediation required"
exit 0