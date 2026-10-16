#!/usr/bin/env python3
"""Generate iterm2/dotfiles.json, the iTerm2 Dynamic Profile.

Colors come from the themes bundled with Ghostty, which are taken from
iTerm2-Color-Schemes (https://iterm2colorschemes.com/). The theme names are
read from the `theme = dark:…,light:…` line in config/ghostty/config.ghostty,
so both terminals always use the same palettes.

Run after changing Ghostty's theme line or updating Ghostty:

    python3 iterm2/generate.py

Set GHOSTTY_THEMES to the themes directory if Ghostty isn't installed in the
default place for macOS or Linux.
"""

import json
import os
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
GHOSTTY_CONFIG = REPO / "config/ghostty/config.ghostty"
OUTPUT = REPO / "iterm2/dotfiles.json"
THEME_DIRS = [
    os.environ.get("GHOSTTY_THEMES", ""),
    "/Applications/Ghostty.app/Contents/Resources/ghostty/themes",
    "/usr/share/ghostty/themes",
]

# Profile settings other than colors: match Ghostty's font and keys.
PROFILE = {
    "Name": "Dotfiles",
    "Guid": "7d1f3c2e-5b8a-4e6f-9c0d-2a1b3c4d5e6f",
    "Normal Font": "FiraCode-Regular 12",
    "Use Non-ASCII Font": True,
    "Non Ascii Font": "SymbolsNFM 12",  # Nerd Font icons (font-symbols-only-nerd-font)
    "Vertical Spacing": 1.25,  # line height, like Ghostty's adjust-cell-height = 25%
    "Option Key Sends": 2,  # left Option: Esc+ (Alt/Meta)
    "Right Option Key Sends": 0,  # right Option: normal (special characters)
    "Unlimited Scrollback": False,
    "Scrollback Lines": 100000,
    "Use Separate Colors for Light and Dark Mode": True,
    "Use Bright Bold": True,  # bold text in bright colors, like Ghostty's bold-is-bright
}

# Ghostty theme keys -> iTerm2 colour keys
KEYS = {
    "background": ["Background Color"],
    "foreground": ["Foreground Color", "Bold Color"],  # Bold Color only applies if a custom bold colour is on
    "cursor-color": ["Cursor Color"],
    "cursor-text": ["Cursor Text Color"],
    "selection-background": ["Selection Color"],
    "selection-foreground": ["Selected Text Color"],
}


def theme_names():
    text = GHOSTTY_CONFIG.read_text()
    match = re.search(r"^theme\s*=\s*\"?dark:([^,]+),\s*light:([^\"\n]+)\"?", text, re.M)
    if not match:
        sys.exit(f"{GHOSTTY_CONFIG}: expected a line like theme = \"dark:A,light:B\"")
    return match.group(1).strip(), match.group(2).strip()


def theme_file(name):
    for directory in filter(None, THEME_DIRS):
        path = Path(directory) / name
        if path.is_file():
            return path
    sys.exit(f"Ghostty theme '{name}' not found; set GHOSTTY_THEMES to Ghostty's themes directory")


def iterm_colour(hex_colour):
    value = hex_colour.lstrip("#")
    red, green, blue = (int(value[i : i + 2], 16) / 255 for i in (0, 2, 4))
    return {
        "Red Component": red,
        "Green Component": green,
        "Blue Component": blue,
        "Alpha Component": 1,
        "Color Space": "sRGB",
    }


def colors(name):
    result = {}
    for line in theme_file(name).read_text().splitlines():
        if match := re.match(r"\s*palette\s*=\s*(\d+)\s*=\s*(#[0-9a-fA-F]{6})", line):
            result[f"Ansi {match[1]} Color"] = match[2]
        elif match := re.match(r"\s*([a-z-]+)\s*=\s*(#[0-9a-fA-F]{6})", line):
            for key in KEYS.get(match[1], []):
                result[key] = match[2]
    result["Link Color"] = result["Ansi 4 Color"]  # clickable links in the palette's blue
    return result


def main():
    dark, light = theme_names()
    profile = dict(PROFILE)
    for suffix, name in (("Dark", dark), ("Light", light)):
        for key, value in sorted(colors(name).items()):
            profile[f"{key} ({suffix})"] = iterm_colour(value)
    OUTPUT.write_text(json.dumps({"Profiles": [profile]}, indent=2) + "\n")
    print(f"wrote {OUTPUT.relative_to(REPO)} from Ghostty themes '{dark}' and '{light}'")


if __name__ == "__main__":
    main()
