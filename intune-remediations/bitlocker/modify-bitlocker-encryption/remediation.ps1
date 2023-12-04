# File: remediation.ps1
# Description: This script is used to remediate BitLocker encryption method. To be used in conjunction with the detection script.
# Author: Nicholas Tabb
# Date: 12/4/2023
# Version: 1.0 - Initial Release

# ---- Modify the following to suit your needs given your environment ---- #
$desiredEncryptionMethod = "XtsAes256"
# ------------------------------------------------------------------------ #

function Set-BitLockerEncryption {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("XtsAes256", "Aes256")]
        [string]$DesiredEncryptionMethod
    )

    
}


# if current encryption method is not desired, perform remediation
$currentEncryptionMethod = (Get-BitLockerVolume -MountPoint "C:").EncryptionMethod
if ($currentEncryptionMethod -ne $desiredEncryptionMethod) {
    Write-Host "Encryption method is $currentEncryptionMethod, remediation required"
    Set-BitLockerEncryption -DesiredEncryptionMethod $desiredEncryptionMethod
    exit 0
} else {
    Write-Host "Encryption method is $currentEncryptionMethod, remediation not required"
    exit 1
}
