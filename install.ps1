$ErrorActionPreference = "Stop"

$HostName = "org.absolem.firefox_profile_transfer"
$ExtensionId = "profile-tab-transfer@absolem.local"

$SourceDir = Join-Path $PSScriptRoot "native-host"
$InstallDir = Join-Path $env:LOCALAPPDATA "FirefoxProfileTabTransfer"

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    throw "Python 3 was not found. Please install Python 3 first."
}

$PythonVersion = & python --version 2>&1
if ($LASTEXITCODE -ne 0 -or $PythonVersion -notlike "Python 3.*") {
    throw "Python 3 is required. Detected: $PythonVersion"
}


Write-Host "Installing Firefox Profile Tab Transfer..."

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$HostScript = Join-Path $InstallDir "transfer.py"
$HostLauncher = Join-Path $InstallDir "launch.bat"
$ManifestPath = Join-Path $InstallDir "$HostName.json"

Copy-Item (Join-Path $SourceDir "transfer.py") $HostScript -Force
Copy-Item (Join-Path $SourceDir "launch.bat") $HostLauncher -Force

$Manifest = @{
    name = $HostName
    description = "Firefox Profile Tab Transfer"
    path = $HostLauncher
    type = "stdio"
    allowed_extensions = @($ExtensionId)
}

$Json = $Manifest | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText(
    $ManifestPath,
    $Json,
    [System.Text.UTF8Encoding]::new($false)
)

$RegistryPath = "HKCU:\Software\Mozilla\NativeMessagingHosts\$HostName"

New-Item -Path $RegistryPath -Force | Out-Null
Set-Item -Path $RegistryPath -Value $ManifestPath

Write-Host ""
Write-Host "Installation completed successfully!"
Write-Host "Native host: $HostLauncher"
Write-Host "Manifest:    $ManifestPath"
