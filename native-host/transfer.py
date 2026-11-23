#!/usr/bin/python

import configparser
import json
import os
import struct
import subprocess
import sys
from urllib.parse import urlsplit

PROFILES_INI = os.path.expanduser(
    "~/.mozilla/firefox/profiles.ini"
)
FIREFOX = "/usr/bin/firefox"

SUPPORTED_SCHEMES = ("http", "https", "about", "file")


def read_message():
    raw_length = sys.stdin.buffer.read(4)
    if len(raw_length) != 4:
        return None

    length = struct.unpack("<I", raw_length)[0]
    if length > 1024 * 1024:
        raise ValueError("Message too large")

    data = sys.stdin.buffer.read(length)
    if len(data) != length:
        raise ValueError("Incomplete message")

    return json.loads(data.decode("utf-8"))


def send_message(message):
    data = json.dumps(message).encode("utf-8")
    sys.stdout.buffer.write(struct.pack("<I", len(data)))
    sys.stdout.buffer.write(data)
    sys.stdout.buffer.flush()


def get_profiles():
    config = configparser.ConfigParser(interpolation=None)
    config.read(PROFILES_INI)

    profiles = []

    for section in config.sections():
        if section.startswith("Profile"):
            name = config.get(section, "Name", fallback=None)
            if name:
                profiles.append(name)

    return profiles


def transfer(profile, urls):
    if profile not in get_profiles():
        raise ValueError("Unknown Firefox profile")

    if not isinstance(urls, list) or not urls:
        raise ValueError("No URLs provided")

    supported_urls = []

    for url in urls:
        if not isinstance(url, str):
            continue

        if urlsplit(url).scheme in SUPPORTED_SCHEMES:
            supported_urls.append(url)

    skipped = len(urls) - len(supported_urls)

    if not supported_urls:
        raise ValueError("No transferable URLs found")

    opened = 0
    failed = []

    for url in supported_urls:
        try:
            result = subprocess.run(
                [FIREFOX, "-P", profile, "--new-tab", url],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
                timeout=15
            )

            if result.returncode == 0:
                opened += 1
            else:
                failed.append(url)

        except (subprocess.TimeoutExpired, OSError):
            failed.append(url)

    return {
        "ok": opened > 0,
        "count": opened,
        "skipped": skipped,
        "failed": len(failed),
        "profile": profile
    }


def main():
    message = read_message()

    if message is None:
        return

    action = message.get("action")

    if action == "list_profiles":
        send_message({
            "ok": True,
            "profiles": get_profiles()
        })

    elif action == "transfer":
        result = transfer(
            message.get("profile"),
            message.get("urls", [])
        )
        send_message(result)

    else:
        raise ValueError("Unknown action")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        send_message({
            "ok": False,
            "error": str(error)
        })
