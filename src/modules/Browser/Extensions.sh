#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

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

detect_default_browser() {
    local default_browser
    if command -v xdg-settings &> /dev/null; then
        default_browser=$(xdg-settings get default-web-browser 2> /dev/null | sed 's/\.desktop//')
    fi
    if [ -z "$default_browser" ] && [ -f ~/.config/mimeapps.list ]; then
        default_browser=$(grep -E "text/html=" ~/.config/mimeapps.list | head -1 | sed 's/text\/html=//' | sed 's/\.desktop.*//' | sed 's/;.*//')
    fi
    echo "${default_browser:-Unknown}"
}

open_url() {
    local url="$1"
    echo -e "${CYAN}Opening: ${BOLD}$url${NC}"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    else
        echo -e "${RED}Could not find xdg-open or open. Please open the URL manually.${NC}"
    fi
}

select_extensions() {
    local browser_type=$1
    local -n extensions_map=$2

    local extension_names=()
    for name in "${!extensions_map[@]}"; do
        extension_names+=("$name")
    done
    IFS=$'\n' extension_names=($(sort <<< "${extension_names[*]}"))
    unset IFS

    while true; do
        clear
        echo -e "${GREEN}Available ${BOLD}$(echo "$browser_type" | tr '[:lower:]' '[:upper:]')${NC}${GREEN} extensions:${NC}"

        for i in "${!extension_names[@]}"; do
            printf "  ${YELLOW}%2d${NC}) %s\n" "$((i + 1))" "${extension_names[i]}"
        done

        echo -ne "${CYAN}Enter number(s) to install (e.g., 1 3 5), 'a' for all, or 'b' to go back: ${NC}"
        read -r -a choices

        if [[ " ${choices[*]} " =~ " b " ]]; then
            clear
            return
        fi

        local selected_for_install=()
        if [[ " ${choices[*]} " =~ " a " ]]; then
            selected_for_install=("${extension_names[@]}")
        else
            for choice in "${choices[@]}"; do
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#extension_names[@]}" ]; then
                    selected_for_install+=("${extension_names[$((choice - 1))]}")
                else
                    echo -e "${RED}Invalid selection: '$choice'. Please try again.${NC}"
                    sleep 2
                    continue 2
                fi
            done
        fi

        if [ ${#selected_for_install[@]} -eq 0 ]; then
            echo -e "${YELLOW}No extensions selected.${NC}"
            sleep 1
            continue
        fi

        echo -e "\n${GREEN}The following extensions will be opened:${NC}"
        for name in "${selected_for_install[@]}"; do
            echo -e "  ${CYAN}• ${BOLD}$name${NC}"
        done

        read -rp "$(echo -e "\n${CYAN}Press ENTER to confirm and open, or Ctrl+C to cancel: ${NC}")"

        for name in "${selected_for_install[@]}"; do
            open_url "${extensions_map[$name]}"
            sleep 1
        done

        echo -e "\n${GREEN}${BOLD}All selected extensions have been opened in your browser.${NC}"
        echo -e "${YELLOW}Note: You still need to complete the installation in the browser.${NC}"
        read -rp "$(echo -e "\n${CYAN}Press ENTER to return to the main menu...${NC}")"
        clear
        return
    done
}

main() {
    while true; do
        clear
        local default_browser
        default_browser=$(detect_default_browser)

        echo -e "${YELLOW}Detected default browser: ${BOLD}$default_browser${NC}"
        echo -e "${YELLOW}NOTE: Extensions will open in your default browser.${NC}"
        echo -e "${YELLOW}Make sure your selection matches your default browser type.${NC}\n"

        PS3="$(echo -e "${CYAN}Select your browser type: ${NC}")"
        options=("Chromium-based" "Firefox-based" "Exit")

        select browser_choice in "${options[@]}"; do
            case $browser_choice in
                "Chromium-based")
                    select_extensions "Chromium" chromium_extensions
                    break
                    ;;
                "Firefox-based")
                    select_extensions "Firefox" firefox_extensions
                    break
                    ;;
                "Exit")
                    echo -e "${YELLOW}Exiting...${NC}"
                    return 0
                    ;;
                *)
                    echo -e "${RED}Invalid option $REPLY. Please try again.${NC}"
                    sleep 1
                    break
                    ;;
            esac
        done
    done
}

main
