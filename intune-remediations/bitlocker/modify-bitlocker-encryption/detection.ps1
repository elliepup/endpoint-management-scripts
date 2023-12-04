# File: detection.ps1
# Description: Checks if the device is encrypted with BitLocker and if the encryption method is a specific value.
# Author: Nicholas Tabb
# Date: 12/4/2023
# Version: 1.0 - Initial Release


# ---- Modify the following to suit your needs given your environment ---- #
$acceptableEncryptionMethods = @("XtsAes256", "Aes256")
# ------------------------------------------------------------------------ #

$encryptionMethod = (Get-BitLockerVolume -MountPoint "C:").EncryptionMethod

if ($encryptionMethod -in $acceptableEncryptionMethods) {
    Write-Host "Encryption method is $encryptionMethod, remediation not required"
    exit 0
} else {
    Write-Host "Encryption method is $encryptionMethod, remediation required"
    exit 1
}