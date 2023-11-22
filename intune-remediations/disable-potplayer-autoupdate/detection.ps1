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
    }
    else {
        return $installDir
    }
}

function Get-CurrentUserConfig {
    # under roaming appdata, there is a config file for potplayer. this is where the autoupdate setting is stored
    $configDir = Join-Path $env:APPDATA "PotPlayerMini64"
    # get all .ini files in the directory
    $configFile = Get-ChildItem -Path $configDir -Filter "*.ini" -File -ErrorAction SilentlyContinue

    # if no config file exists, return null; else return the config file
    if (-NOT $configFile) {
        return $null
    }
    else {
        return $configFile[0]
    }
}

function Get-ConfigValue {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$configFile,
        [Parameter(Mandatory = $true)]
        [string]$key
    )

    # read the config file and return the value of the key
    process {
        $value = Get-Content -Path $configFile | Select-String -Pattern "$key=" | Select-Object -ExpandProperty Line
        
        # if value is null, return null; else return the value after the equals sign
        if ($null -eq $value) {
            return $null
        }
        else {
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

# if config file does not exist, exit 1; remediation is required
if ($null -eq $configFile) {
    Write-Host "PotPlayer config file does not exist on the device. Remediation is required." -ForegroundColor Red
    exit 1
}
$autoUpdateValue = $configFile | Get-ConfigValue -key "CheckAutoUpdate"

# if does not exist or is set to 1, exit 1; remediation is required
if ($null -eq $autoUpdateValue -or $autoUpdateValue -eq "1") {
    Write-Host "PotPlayer autoupdate is enabled on the device. Remediation is required." -ForegroundColor Red
    exit 1
}

# if set to 0, exit 0; remediation is not applicable
if ($autoUpdateValue -eq "0") {
    Write-Host "PotPlayer autoupdate is disabled on the device. Remediation is not applicable to this device." -ForegroundColor Green
    exit 0
}