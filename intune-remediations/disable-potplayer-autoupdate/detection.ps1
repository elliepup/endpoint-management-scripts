# File: detection.ps1
# Description: This script is used to detect if PotPlayer autoupdate is enabled on the device. To be used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 11/21/2023
# Version: 1.0 - Initial Release

# confirm potplayer is installed

function Get-PotPlayer {
    $installDir = Join-Path $env:ProgramFiles "DAUM\PotPlayer"
    # if potplayer is not installed, return null; else return the install directory
    if (!(Test-Path -Path $installDir)) {
        return $null
    } else {
        return $installDir
    }
}

function Get-CurrentUserConfig {
    # under roaming appdata, there is a config file for potplayer. this is where the autoupdate setting is stored
    $configDir = Join-Path $env:APPDATA "PotPlayerMini64"
    $configFile = (Get-ChildItem -Path $configDir -Filter "*.ini" -Recurse -ErrorAction SilentlyContinue)[0].FullName

    # if config file does not exist, return null; else return the config file
    if (!(Test-Path -Path $configFile)) {
        return $null
    } else {
        return $configFile
    }
}

function Get-ConfigValue {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$configFile,
        [Parameter(Mandatory=$true)]
        [string]$key
    )

    # read the config file and return the value of the key
    process {
        $value = Get-Content -Path $configFile | Select-String -Pattern "$key=" | Select-Object -ExpandProperty Line
        
        # if value is null, return null; else return the value after the equals sign
        if ($null -eq $value) {
            return $null
        } else {
            return $value.Split("=")[1]
        }
    }
}

$installDir = Get-PotPlayer 

# if potplayer is not installed, exit 0; remediation is not applicable
if ($null -eq $installDir) {
    Write-Host "PotPlayer is not installed on the device. Remediation is not applicable to this device." -ForegroundColor Green
    exit 0
}

$configFile = Get-CurrentUserConfig
$autoUpdateValue = $configFile | Get-ConfigValue -key "CheckAutoUpdate"

# finish this later