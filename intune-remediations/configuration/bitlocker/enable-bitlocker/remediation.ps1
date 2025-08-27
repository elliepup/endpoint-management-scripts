# File: remediation.ps1
# Description: This script is used to enable bitlocker on the device. To be used in conjunction with the detection script.
# Author: Nicholas Tabb
# Date: 11/17/2023
# Version: 1.0 - Initial Release

# get the tpm status
$tpmStatus = Get-Tpm

# if tpm is not ready or not present, attempt to enable tpm
if ($tpmStatus.TpmReady -eq $false -or $tpmStatus.TpmPresent -eq $false) {
    Write-Host "TPM is not ready or not present. Attempting to enable TPM..." -ForegroundColor Yellow
    Enable-TpmAutoProvisioning
    Write-Host "TPM has been enabled. The device may need to restart prior to enabling BitLocker, but will proceed with enabling BitLocker now."
}

# get bitlocker status
$status = Get-BitLockerVolume -MountPoint "C:"
$keyProtector = $status.KeyProtector

# try to enable bitlocker
try {
    # ideally we want tpm and recovery password as key protectors. chances are, we have neither. if count is less than or equal to 1, we need to add them
    if ($keyProtector.Count -le 1) {
        Write-Host "TPM and/or recovery password are not key protectors. Adding them now..." -ForegroundColor Yellow
    
        # if tpm is not a key protector, add it
        if ($keyProtector.KeyProtectorType -notcontains "Tpm") {
            Add-BitLockerKeyProtector -MountPoint "C:" -TpmProtector
            Write-Host "TPM has been added as a key protector." -ForegroundColor Green
        }

        # if recovery password is not a key protector, add it
        if ($keyProtector.KeyProtectorType -notcontains "RecoveryPassword") {
            Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
            Write-Host "Recovery password has been added as a key protector." -ForegroundColor Green
        }
    }

    # if drive is encrypted but protection is off, resume protection
    if ($status.ProtectionStatus -eq "Off" -and $status.EncryptionPercentage -eq 100) {
        Write-Host "Drive is encrypted but protection is off. Resuming protection..." -ForegroundColor Yellow
        Resume-BitLocker -MountPoint "C:"
        Write-Host "Protection has been resumed." -ForegroundColor Green
    }

    # if drive is decrypted, enable BitLocker. use xtsaes256. can be changed if desired or if 256 is overkill for your environment
    if ($status.ProtectionStatus -eq "Off" -and $status.EncryptionPercentage -eq 0) {
        Write-Host "Drive is decrypted. Enabling BitLocker..." -ForegroundColor Yellow
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -RecoveryPasswordProtector -SkipHardwareTest
        Write-Host "BitLocker has been enabled." -ForegroundColor Green
    }

    # check to see if bitlocker is enabled or in the process of encrypting. if so, exit 0
    $status = Get-BitLockerVolume -MountPoint "C:"
    if ($status.ProtectionStatus -eq "On" -or $status.EncryptionPercentage -ne 0) {
        Write-Host "BitLocker is enabled or in the process of encrypting. Remediation was successful." -ForegroundColor Green
        exit 0
    } else {
        # the device may need to be restarted or TPM may be disabled in bios. depending on your environment, this may or may not be easy to implement
        Write-Host "BitLocker is not enabled and the device is not in the process of encrypting. Please try again." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "An error occurred while attempting to enable BitLocker. Please try again." -ForegroundColor Red
    exit 1
}