# File: detection.ps1
# Description: This script checks if any of the bloatware apps are installed or provisioned. To be used in conjunction with the remediation script.
# Author: Nicholas Tabb
# Date: 11/16/2023
# Version: 1.0 - Initial Release

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
$allApps = $apps | Get-AppStatus | Where-Object { $_.Installed -or $_.Provisioned }

# if app is installed or provisioned, exit with a status of 1; remediation required
if ($allApps) {
    Write-Host "Bloatware detected. Remediation required." -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "No bloatware detected. No remediation required." -ForegroundColor Green
    exit 0
}