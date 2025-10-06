<#
.SYNOPSIS
Detects the presence of pre-installed applications, commonly referred to as "bloatware", on Windows 10 and 11 devices. This also removes the bloatware if it is detected.

.DESCRIPTION
This PowerShell script checks for the presence of a predefined list of applications and determines whether they are installed or provisioned. If any of the applications are detected, the script will attempt to uninstall them. If any of the applications are still installed or provisioned after the script runs, the script exits with a status of 1, indicating that remediation is required. If no applications are detected, the script exits with a status of 0, indicating that no remediation is required.

.EXAMPLE
.\remediation.ps1

.NOTES
Author: Nicholas Tabb
Date: 10/23/2023
Version: 1.0 - Initial Release
#>

$apps = @( 			
    "Microsoft.549981C3F5F10",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.GamingApp",
    "Microsoft.BingNews",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# get the installation/provisioning status of each app; return an array of objects
function Get-AppStatus {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$AppNames
    )

    # initialize the lists of apps
    begin {
        $apps = @()
        $allInstalledApps = Get-AppxPackage -AllUsers | Select-Object -ExpandProperty Name
        $allProvisionedApps = Get-AppxProvisionedPackage -Online | Select-Object -ExpandProperty DisplayName
    }

    # process each app
    process {
        foreach ($app in $AppNames) {

            # create a custom object to store the app name, and whether it is installed or provisioned
            $appStatus = [PSCustomObject]@{
                AppName     = $app
                Installed   = $false
                Provisioned = $false
            }

            # check if app is installed or provisioned and set the appropriate property to true
            if ($allInstalledApps -contains $app) {
                $appStatus.Installed = $true
            }

            if ($allProvisionedApps -contains $app) {
                $appStatus.Provisioned = $true
            }

            # add the app to the list
            $apps += $appStatus
        }
    }

    end {
        # return the list of apps
        $apps
    }
}

function Remove-Bloatware {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [pscustomobject[]]$Apps
    )

    # process each app
    process {

        Write-Host "Uninstalling the app: $($Apps.AppName)" -ForegroundColor Yellow

        # try to uninstall the app
        try {
            # uninstall the app if it is installed
            if ($Apps.Installed) {
                Get-AppxPackage -Name $Apps.AppName -AllUsers | Remove-AppxPackage -AllUsers
            }

            # uninstall the app if it is provisioned
            if ($Apps.Provisioned) {
                Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $Apps.AppName } | Remove-AppxProvisionedPackage -Online
            }
        } catch {
            Write-Host "Failed to uninstall the app: $($Apps.AppName)" -ForegroundColor Red
            Write-Error -Message $_.Exception.Message
        }        
    }
}

# 1: get the installation/provisioning status of each app
# 2: filter the list to only include apps that are installed or provisioned
# 3: remove the bloatware
$allApps = $apps | Get-AppStatus | Where-Object { $_.Installed -or $_.Provisioned } | Remove-Bloatware

# if any apps are still installed or provisioned, exit with a status of 1; remediation required
$allApps = $apps | Get-AppStatus | Where-Object { $_.Installed -or $_.Provisioned }
if ($allApps) {
    Write-Host "Bloatware still detected. Remediation required." -ForegroundColor Red
    $allApps | Format-Table
    exit 1
} else {
    Write-Host "No bloatware detected." -ForegroundColor Green
    exit 0
}