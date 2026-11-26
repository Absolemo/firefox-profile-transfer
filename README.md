# Firefox Profile Tab Transfer

A Firefox extension for transferring tabs between different Firefox profiles.

## Features

- Send an individual tab to another Firefox profile.
- Send multiple selected tabs at once.
- Send all tabs from the current window.
- Automatically detect Firefox profiles from `profiles.ini`.
- Reuse already running Firefox profile instances.
- Keep the original tabs open after transferring.
- Skip unsupported URLs instead of aborting the entire transfer.
- Cross-platform native host for Linux and Windows.

## Requirements

### Linux

- Mozilla Firefox
- Python 3
- Bash

### Windows

- Mozilla Firefox
- Python 3
- Windows PowerShell

Python must be installed and available through the `python` command.

## Project Structure

```text
firefox-profile-transfer/
├── extension/
│   ├── manifest.json
│   └── background.js
├── native-host/
│   ├── transfer.py
│   └── launch.bat
├── install.sh
├── uninstall.sh
├── install.ps1
├── uninstall.ps1
├── .gitignore
├── LICENSE
└── README.md
```

## Installation

Clone or download this repository.

### Linux

Run the installer:

```bash
chmod +x install.sh
./install.sh
```

The installer copies the native messaging host to:

```text
~/.local/share/firefox-profile-transfer/
```

It registers the native messaging host in:

```text
~/.mozilla/native-messaging-hosts/
```

### Windows

Make sure Python 3 is installed and available through the `python` command.

Open PowerShell in the project directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer copies the native messaging host to:

```text
%LOCALAPPDATA%\FirefoxProfileTabTransfer\
```

It also registers the native messaging host in the current Windows user registry. Administrator privileges are not required.

## Installing the Firefox Extension

The extension can currently be loaded temporarily for development:

1. Open `about:debugging#/runtime/this-firefox` in Firefox.
2. Click **Load Temporary Add-on...**
3. Select `extension/manifest.json`.

Temporary extensions are removed when Firefox restarts.

For permanent installation, the extension needs to be signed by Mozilla. An AMO release is planned.

The native messaging host must be installed separately on each operating system.

## Usage

Right-click a tab to open the context menu.

Choose **Send to another profile** and select one of the available actions:

- **Send selected tabs**
- **Send all tabs in this window**

Then choose the destination Firefox profile.

Original tabs remain open after transfer.

## Uninstallation

### Linux

Run:

```bash
./uninstall.sh
```

### Windows

Open PowerShell in the project directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Both uninstallers remove the native messaging host and its registration.

Remove the Firefox extension separately through Firefox.

## Development Status

This project is under active development.

## License

MIT License. See [LICENSE](LICENSE).
