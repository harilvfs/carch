#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from carch_lib import (
    CYAN,
    NC,
    confirm,
    get_choice,
    print_error,
    print_info,
    print_success,
    print_warning,
    show_menu,
)

CHROMIUM_EXTENSIONS = {
    "Adblock Plus": "https://chromewebstore.google.com/detail/adblock-plus-free-ad-bloc/cfhdojbkjhnklbpkdaibdccddilifddb",
    "ClearURLs": "https://chromewebstore.google.com/detail/clearurls/lckanjgmijmafbedllaakclkaicjfmnk",
    "Dark Reader": "https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh",
    "Enhancer for YouTube": "https://chromewebstore.google.com/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle",
    "Ghostery Private Search": "https://chromewebstore.google.com/detail/ghostery-private-search-f/nomidcdbhopffbhbpfnnlgnfimhgdman",
    "Ghostery Tracker & Ad Blocker": "https://chromewebstore.google.com/detail/ghostery-tracker-ad-block/mlomiejdfkolichcflejclcbmpeaniij",
    "Improve Tube": "https://chromewebstore.google.com/detail/improve-youtube-%F0%9F%8E%A7-for-yo/bnomihfieiccainjcjblhegjgglakjdd",
    "JoyPixels": "https://chromewebstore.google.com/detail/emoji-keyboard-by-joypixe/ipdjnhgkpapgippgcgkfcbpdpcgifncb",
    "Material Icons for GitHub": "https://chromewebstore.google.com/detail/material-icons-for-github/bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc",
    "Sapling Grammar Checker": "https://chromewebstore.google.com/detail/sapling-grammar-checker-a/pjpgohokimaldkikgejifibjdpbopfdc",
    "SponsorBlock for YouTube": "https://chromewebstore.google.com/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone",
    "Tabliss": "https://chromewebstore.google.com/detail/tabliss-a-beautiful-new-t/hipekcciheckooncpjeljhnekcoolahp",
    "uBlock Origin": "https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm",
    "uBlock Origin Lite": "https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh",
    "WakaTime": "https://chromewebstore.google.com/detail/wakatime/jnbbnacmeggbgdjgaoojpmhdlkkpblgi",
    "Web Highlighter": "https://chromewebstore.google.com/detail/web-highlights-pdf-web-hi/hldjnlbobkdkghfidgoecgmklcemanhm",
}

FIREFOX_EXTENSIONS = {
    "Adblock Plus": "https://addons.mozilla.org/en-US/firefox/addon/adblock-plus/",
    "ClearURLs": "https://addons.mozilla.org/en-US/firefox/addon/clearurls/",
    "Dark Reader": "https://addons.mozilla.org/en-US/firefox/addon/darkreader/",
    "Emoji": "https://addons.mozilla.org/en-US/firefox/addon/emoji-sav/",
    "Enhancer for YouTube": "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/",
    "Ghostery Private Search": "https://addons.mozilla.org/en-US/firefox/addon/ghostery-private-search/",
    "Ghostery Tracker & Ad Blocker": "https://addons.mozilla.org/en-US/firefox/addon/ghostery/",
    "Improve YouTube": "https://addons.mozilla.org/en-US/firefox/addon/youtube-addon/",
    "LanguageTool": "https://addons.mozilla.org/en-US/firefox/addon/languagetool/",
    "Material Icon for GitHub": "https://addons.mozilla.org/en-US/firefox/addon/material-icon-for-github/",
    "SponsorBlock": "https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/",
    "Tabliss": "https://addons.mozilla.org/en-US/firefox/addon/tabliss/",
    "uBlock Origin": "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/",
    "WakaTime": "https://addons.mozilla.org/en-US/firefox/addon/wakatimes/",
}


def detect_browser():
    if shutil.which("xdg-settings"):
        try:
            result = subprocess.run(
                ["xdg-settings", "get", "default-web-browser"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            browser = result.stdout.strip().replace(".desktop", "")
            if browser:
                return browser
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass

    mime_path = os.path.expanduser("~/.config/mimeapps.list")
    if os.path.isfile(mime_path):
        with open(mime_path) as f:
            for line in f:
                if line.startswith("text/html="):
                    browser = line.split("=", 1)[1].strip().split(".")[0].split(";")[0]
                    if browser:
                        return browser
    return "Unknown"


def open_url(url):
    print_info(f"Opening: {url}")
    for cmd in ("xdg-open", "open"):
        if shutil.which(cmd):
            subprocess.Popen(
                [cmd, url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            return
    print_error("Could not find xdg-open or open. Please open the URL manually.")


def select_extensions(browser_type, extensions):
    names = sorted(extensions.keys())

    while True:
        os.system("clear" if os.name == "posix" else "cls")
        title = f"Available {browser_type.upper()} extensions"
        show_menu(title, names)

        try:
            raw = input(
                f"{CYAN}:: Enter number(s) to install (e.g., 1 3 5), "
                f"'a' for all, or 'b' to go back: {NC}"
            )
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        choices = raw.split()

        if "b" in choices:
            return

        selected = []
        if "a" in choices:
            selected = names[:]
        else:
            for c in choices:
                if c.isdigit() and 1 <= int(c) <= len(names):
                    selected.append(names[int(c) - 1])
                else:
                    print_error(f"Invalid selection: '{c}'.")
                    break
            else:
                if not selected:
                    print_warning("No extensions selected.")
                    continue

        if not selected:
            continue

        print_success("The following extensions will be opened:")
        for name in selected:
            print(f"    {CYAN}{name}{NC}")
        print()

        if not confirm("Open selected extensions?"):
            print_warning("Installation cancelled.")
            continue

        for name in selected:
            open_url(extensions[name])

        print()
        print_success("All selected extensions have been opened in your browser.")
        print_warning(
            "Note: You still need to complete the installation in the browser."
        )
        try:
            input(f"\n{CYAN}:: Press ENTER to return to the main menu...{NC}")
        except (KeyboardInterrupt, EOFError):
            print()
            sys.exit(0)
        return


def main():
    while True:
        os.system("clear" if os.name == "posix" else "cls")
        default_browser = detect_browser()

        print_warning(f"Detected default browser: {default_browser}")
        print_warning("NOTE: Extensions will open in your default browser.")
        print_warning("Make sure your selection matches your default browser type.")

        options = ["Chromium-based", "Firefox-based", "Exit"]
        show_menu("Select your browser type", options)

        choice_idx = get_choice(len(options))
        choice = options[choice_idx - 1]

        if choice == "Chromium-based":
            select_extensions("Chromium", CHROMIUM_EXTENSIONS)
        elif choice == "Firefox-based":
            select_extensions("Firefox", FIREFOX_EXTENSIONS)
        elif choice == "Exit":
            return


if __name__ == "__main__":
    main()
