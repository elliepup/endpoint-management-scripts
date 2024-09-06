<#
.SYNOPSIS
Uninstalls the classic Teams application for the current user.
.DESCRIPTION
Uninstalls the classic Teams application for the current user. The function retrieves the path to the Teams update executable and runs the executable with the uninstall
arguments. The function will wait for the uninstall process to complete before exiting.
.EXAMPLE
.\remediation.ps1
Uninstalls the classic Teams application for the current user.
.NOTES
File Name      : remediation.ps1
Author         : Nicholas Tabb
Date           : 09/06/2024
Context        : User (Interactive)
#>

function Uninstall-ClassicTeamsForCurrentUser {
    <#
    .SYNOPSIS
    Uninstalls the classic Teams application for the current user.
    .DESCRIPTION
    Uninstalls the classic Teams application for the current user. The function retrieves the path to the Teams update executable and runs the executable with the uninstall
    arguments. The function will wait for the uninstall process to complete before exiting.
    .EXAMPLE
    Uninstall-ClassicTeamsForCurrentUser
    Uninstalls the classic Teams application for the current user.
    #>
    $updatePath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Teams\Update.exe"
    $updateArgs = "--uninstall -s"
    Start-Process -FilePath $updatePath -ArgumentList $updateArgs -Wait
}

Uninstall-ClassicTeamsForCurrentUser