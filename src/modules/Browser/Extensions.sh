#!/usr/bin/env bash

# Useful Extensions for Chromium or Firefox based browsers.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

FZF_COMMON="--layout=reverse \
            --border=bold \
            --border=rounded \
            --margin=5% \
            --color=dark \
            --info=inline \
            --header-first \
            --bind change:top"

declare -A chromium_extensions=(
    ["Improve Tube"]="https://chromewebstore.google.com/detail/improve-youtube-%F0%9F%8E%A7-for-yo/bnomihfieiccainjcjblhegjgglakjdd"
    ["Enhancer for YouTube"]="https://chromewebstore.google.com/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle"
    ["Adblock Plus"]="https://chromewebstore.google.com/detail/adblock-plus-free-ad-bloc/cfhdojbkjhnklbpkdaibdccddilifddb"
    ["ClearURLs"]="https://chromewebstore.google.com/detail/clearurls/lckanjgmijmafbedllaakclkaicjfmnk"
    ["JoyPixels"]="https://chromewebstore.google.com/detail/emoji-keyboard-by-joypixe/ipdjnhgkpapgippgcgkfcbpdpcgifncb"
    ["Material Icons for GitHub"]="https://chromewebstore.google.com/detail/material-icons-for-github/bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc"
    ["Sapling Grammar Checker"]="https://chromewebstore.google.com/detail/sapling-grammar-checker-a/pjpgohokimaldkikgejifibjdpbopfdc"
    ["SponsorBlock for YouTube"]="https://chromewebstore.google.com/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone"
    ["Tabliss"]="https://chromewebstore.google.com/detail/tabliss-a-beautiful-new-t/hipekcciheckooncpjeljhnekcoolahp"
    ["uBlock Origin"]="https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm"
    ["uBlock Origin Lite"]="https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh"
    ["WakaTime"]="https://chromewebstore.google.com/detail/wakatime/jnbbnacmeggbgdjgaoojpmhdlkkpblgi"
    ["Web Highlighter"]="https://chromewebstore.google.com/detail/web-highlights-pdf-web-hi/hldjnlbobkdkghfidgoecgmklcemanhm"
    ["Ghostery Tracker & Ad Blocker"]="https://chromewebstore.google.com/detail/ghostery-tracker-ad-block/mlomiejdfkolichcflejclcbmpeaniij"
    ["Ghostery Private Search"]="https://chromewebstore.google.com/detail/ghostery-private-search-f/nomidcdbhopffbhbpfnnlgnfimhgdman"
)

declare -A firefox_extensions=(
    ["Tabliss"]="https://addons.mozilla.org/en-US/firefox/addon/tabliss/"
    ["Enhancer for YouTube"]="https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/"
    ["Improve YouTube"]="https://addons.mozilla.org/en-US/firefox/addon/youtube-addon/"
    ["Adblock Plus"]="https://addons.mozilla.org/en-US/firefox/addon/adblock-plus/"
    ["ClearURLs"]="https://addons.mozilla.org/en-US/firefox/addon/clearurls/"
    ["Emoji"]="https://addons.mozilla.org/en-US/firefox/addon/emoji-sav/"
    ["Material Icon for GitHub"]="https://addons.mozilla.org/en-US/firefox/addon/material-icon-for-github/"
    ["LanguageTool"]="https://addons.mozilla.org/en-US/firefox/addon/languagetool/"
    ["SponsorBlock"]="https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/"
    ["uBlock Origin"]="https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/"
    ["WakaTime"]="https://addons.mozilla.org/en-US/firefox/addon/wakatimes/"
    ["Dark Reader"]="https://addons.mozilla.org/en-US/firefox/addon/darkreader/"
    ["Ghostery Tracker & Ad Blocker"]="https://addons.mozilla.org/en-US/firefox/addon/ghostery/"
    ["Ghostery Private Search"]="https://addons.mozilla.org/en-US/firefox/addon/ghostery-private-search/"
)

fzf_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected
    selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                 --height=40% \
                                                 --prompt="$prompt " \
                                                 --header="Select Option" \
                                                 --pointer="➤" \
                                                 --color='fg:white,fg+:blue,bg+:black,pointer:blue')
    echo "$selected"
}

fzf_multiselect() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected
    selected=$(printf "%s\n" "${options[@]}" | fzf ${FZF_COMMON} \
                                                 --height=80% \
                                                 --prompt="$prompt " \
                                                 --header="Select Extensions (TAB to select, ENTER to confirm, ESC to exit)" \
                                                 --pointer="➤" \
                                                 --multi \
                                                 --color='fg:white,fg+:blue,bg+:black,pointer:blue')
    echo "$selected"
}

detect_default_browser() {
    local default_browser

    if command -v xdg-settings &> /dev/null; then
        default_browser=$(xdg-settings get default-web-browser 2>/dev/null | sed 's/\.desktop//')
    fi

    if [ -z "$default_browser" ] && [ -f ~/.config/mimeapps.list ]; then
        default_browser=$(grep -E "text/html=" ~/.config/mimeapps.list | head -1 | sed 's/text\/html=//' | sed 's/\.desktop.*//' | sed 's/;.*//')
    fi

    if [ -z "$default_browser" ]; then
        echo "unknown"
    else
        echo "$default_browser"
    fi
}

open_extension() {
    local url="$1"
    echo -e "${CYAN}Opening extension in default browser...${NC}"
    xdg-open "$url" || open "$url"
}

main() {
    clear

    local default_browser
    default_browser=$(detect_default_browser)

    local browser_choice
    browser_choice=$(fzf_select "Select your browser type:" "Chromium-based" "Firefox-based" "Exit")

    if [ "$browser_choice" == "Exit" ]; then
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi

    local browser_type
    if [ "$browser_choice" == "Chromium-based" ]; then
        browser_type="chromium"
    elif [ "$browser_choice" == "Firefox-based" ]; then
        browser_type="firefox"
    else
        echo -e "${RED}Invalid choice. Exiting...${NC}"
        exit 1
    fi

    echo -e "${GREEN}Selected browser type: ${BOLD}$browser_choice${NC}"
    echo -e "${YELLOW}Default browser detected: ${BOLD}$default_browser${NC}"
    echo -e "${YELLOW}NOTE: Extensions will open in your default browser.${NC}"
    echo -e "${YELLOW}Make sure your selection matches your default browser type.${NC}"
    sleep 0.5

    if [ "$browser_type" == "chromium" ]; then
        local extension_names=("${!chromium_extensions[@]}" "Back to Menu")
        local selected_extensions
        selected_extensions=$(fzf_multiselect "Select Chromium extensions to install:" "${extension_names[@]}")

        if [ -z "$selected_extensions" ]; then
            echo -e "${YELLOW}No extensions selected. Returning to main menu...${NC}"
            sleep 1
            main
            return
        fi

        if echo "$selected_extensions" | grep -q "Back to Menu"; then
            main
            return
        fi

        echo -e "${GREEN}Selected extensions:${NC}"
        echo "$selected_extensions" | while read -r extension; do
            echo -e "  ${CYAN}• ${BOLD}$extension${NC}"
        done

        echo "$selected_extensions" | while read -r extension; do
            local url="${chromium_extensions[$extension]}"
            open_extension "$url"
            sleep 2
        done

        echo -e "${GREEN}${BOLD}All selected extensions have been opened in your browser.${NC}"
        echo -e "${YELLOW}Note: You still need to complete installation in the browser.${NC}"

        echo ""
        echo -e "${CYAN}Press ENTER to return to the main menu...${NC}"
        read
        main

    elif [ "$browser_type" == "firefox" ]; then
        local extension_names=("${!firefox_extensions[@]}" "Back to Menu")
        local selected_extensions
        selected_extensions=$(fzf_multiselect "Select Firefox extensions to install:" "${extension_names[@]}")

        if [ -z "$selected_extensions" ]; then
            echo -e "${YELLOW}No extensions selected. Returning to main menu...${NC}"
            sleep 1
            main
            return
        fi

        if echo "$selected_extensions" | grep -q "Back to Menu"; then
            main
            return
        fi

        echo -e "${GREEN}Selected extensions:${NC}"
        echo "$selected_extensions" | while read -r extension; do
            echo -e "  ${CYAN}• ${BOLD}$extension${NC}"
        done

        echo "$selected_extensions" | while read -r extension; do
            local url="${firefox_extensions[$extension]}"
            open_extension "$url"
            sleep 2
        done

        echo -e "${GREEN}${BOLD}All selected extensions have been opened in your browser.${NC}"
        echo -e "${YELLOW}Note: You still need to complete installation in the browser.${NC}"

        echo ""
        echo -e "${CYAN}Press ENTER to return to the main menu...${NC}"
        read
        main
    fi
}

if ! command -v fzf &> /dev/null; then
    echo -e "${RED}${BOLD}Error: fzf is not installed${NC}"
    echo -e "${YELLOW}Please install fzf before running this script:${NC}"
    echo -e "${CYAN}  • Fedora: ${NC}sudo dnf install fzf"
    echo -e "${CYAN}  • Arch Linux: ${NC}sudo pacman -S fzf"
    exit 1
fi

main
