$applicationName = "Teams Machine-Wide Installer"
function Get-RegistryKey {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$applicationName
    )

    begin {
        $hives = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", 
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
        $keys = @()
    }   

    process {
        foreach ($hive in $hives) {
            $keys += Get-ItemProperty $hive | Where-Object {$_.DisplayName -Like "$applicationName"}
        }
    }

    end {
        return $keys
    }
}

if ($applicationName | Get-RegistryKey) {
    Write-Host "$applicationName found. Remediation is required." -ForegroundColor Red
    exit 1
} else {
    Write-Host "$applicationName not found." -ForegroundColor Green
    exit 0
}
