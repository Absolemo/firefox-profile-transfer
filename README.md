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

## Requirements

- Linux
- Mozilla Firefox
- Python 3
- Bash

## Project Structure

```text
firefox-profile-transfer/
├── extension/
│   ├── manifest.json
│   └── background.js
├── native-host/
│   └── transfer.py
├── install.sh
├── uninstall.sh
├── .gitignore
├── LICENSE
└── README.md
```

## Installation

Clone or download this repository.

Make the installer executable and run it:

```bash
chmod +x install.sh
./install.sh
```

The installer copies the native messaging host to:

```text
~/.local/share/firefox-profile-transfer/
```

It also registers the native messaging host in:

```text
~/.mozilla/native-messaging-hosts/
```

## Loading the Firefox Extension

The extension can currently be loaded temporarily for development:

1. Open `about:debugging#/runtime/this-firefox` in Firefox.
2. Click **Load Temporary Add-on...**
3. Select `extension/manifest.json`.

Temporary extensions are removed when Firefox restarts.

For permanent installation, the extension needs to be signed by Mozilla. An unlisted AMO release is planned.

## Usage

Right-click a tab to open the context menu.

Choose **Send to another profile** and select one of the available actions:

- **Send selected tabs**
- **Send all tabs in this window**

Then choose the destination Firefox profile.

Original tabs remain open after transfer.

## Uninstallation

Run:

```bash
./uninstall.sh
```

This removes the native messaging host and its registration.

Remove the Firefox extension separately through Firefox.

## Development Status

This project is under active development.

## License

MIT License. See [LICENSE](LICENSE).
