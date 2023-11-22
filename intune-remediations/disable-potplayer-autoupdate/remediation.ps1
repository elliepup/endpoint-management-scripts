# File: remediation.ps1
# Description: This script is used to disable PotPlayer autoupdate on the device. To be used in conjunction with the detection script.
# Author: Nicholas Tabb
# Date: 11/22/2023
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

    # if no config file exists, create one
    if (-NOT $configFile) {
        $configFile = New-Item -Path $configDir -Name "PotPlayerMini64.ini" -ItemType File
        return $configFile.FullName
    }
    else {
        return $configFile[0].FullName
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

function Set-ConfigValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$configFile,
        [Parameter(Mandatory = $true)]
        [string]$key,
        [Parameter(Mandatory = $true)]
        [string]$value
    )

    # check to see if the [Settings] section exists in the config file and add it if it does not
    $settingsSection = Get-Content -Path $configFile | Select-String -Pattern "\[Settings\]" | Select-Object -ExpandProperty Line
    if ($null -eq $settingsSection) {
        Add-Content -Path $configFile -Value "[Settings]"
    }

    # check to see if the key exists in the config file and add it if it does not; set to the value
    $keyExists = Get-Content -Path $configFile | Select-String -Pattern "$key=" | Select-Object -ExpandProperty Line
    if ($null -eq $keyExists) {
        Add-Content -Path $configFile -Value "$key=$value"
    }
    else {
        (Get-Content -Path $configFile) | ForEach-Object {$_ -replace "$key=.*","$key=$value"} | Set-Content -Path $configFile
    }
}

$installDir = Get-PotPlayer

# if potplayer is not installed, exit 0; remediation is not applicable
if ($null -eq $installDir) {
    Write-Host "PotPlayer is not installed on the device. Remediation is not applicable to this device." -ForegroundColor Green
    exit 0
}

$configFile = Get-CurrentUserConfig 

# set the value to 0
Set-ConfigValue -configFile $configFile -key "CheckAutoUpdate" -value "0"

# confirm the value was set to 0
$autoUpdateValue = $configFile | Get-ConfigValue -key "CheckAutoUpdate"

# if set to 0, exit 0; remediation is not applicable
if ($autoUpdateValue -eq "0") {
    Write-Host "PotPlayer autoupdate is disabled on the device. Remediation was successful." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "PotPlayer autoupdate is enabled on the device. Remediation failed." -ForegroundColor Red
    exit 1
}