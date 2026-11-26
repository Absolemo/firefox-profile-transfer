$ErrorActionPreference = "Stop"

$HostName = "org.absolem.firefox_profile_transfer"
$InstallDir = Join-Path $env:LOCALAPPDATA "FirefoxProfileTabTransfer"
$RegistryPath = "HKCU:\Software\Mozilla\NativeMessagingHosts\$HostName"

Write-Host "Uninstalling Firefox Profile Tab Transfer..."

if (Test-Path $RegistryPath) {
    Remove-Item -Path $RegistryPath -Force
}

if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force
}

Write-Host ""
Write-Host "Native messaging host removed."
Write-Host "You can now remove the Firefox extension separately."
