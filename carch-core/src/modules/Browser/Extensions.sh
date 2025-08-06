#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh" > /dev/null 2>&1

print_message() {
    local color="$1"
    local message="$2"
    printf "%b:: %s%b\n" "$color" "$message" "$NC"
}

confirm() {
    while true; do
        read -p "$(printf "%b:: %s%b" "$CYAN" "$1 [y/N]: " "$NC")" answer
        case ${answer,,} in
            y | yes) return 0 ;;
            n | no | "") return 1 ;;
            *) print_message "$YELLOW" "Please answer with y/yes or n/no." ;;
        esac
    done
}

show_menu() {
    local title="$1"
    shift
    local options=("$@")

    echo
    print_message "$CYAN" "=== $title ==="
    echo

    for i in "${!options[@]}"; do
        printf "  %b[%d]%b %s\n" "$GREEN" "$((i + 1))" "$NC" "${options[$i]}"
    done
    echo
}

get_choice() {
    local max_option="$1"
    local choice

    while true; do
        read -p "$(printf "%b:: Enter your choice (1-$max_option): %b" "$YELLOW" "$NC")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_option" ]; then
            return "$choice"
        else
            print_message "$RED" "Invalid choice. Please enter a number between 1 and $max_option."
        fi
    done
}

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
    print_message "$CYAN" "Opening: $url"
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    elif command -v open &> /dev/null; then
        open "$url"
    else
        print_message "$RED" "Could not find xdg-open or open. Please open the URL manually."
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
        local title="Available $(echo "$browser_type" | tr '[:lower:]' '[:upper:]') extensions"
        show_menu "$title" "${extension_names[@]}"

        printf "%b:: Enter number(s) to install (e.g., 1 3 5), 'a' for all, or 'b' to go back: %b" "$CYAN" "$NC"
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
                    print_message "$RED" "Invalid selection: '$choice'. Please try again."
                    sleep 2
                    continue 2
                fi
            done
        fi

        if [ ${#selected_for_install[@]} -eq 0 ]; then
            print_message "$YELLOW" "No extensions selected."
            sleep 1
            continue
        fi

        print_message "$GREEN" "The following extensions will be opened:"
        for name in "${selected_for_install[@]}"; do
            printf "    %b• %s%b\n" "$CYAN" "$name" "$NC"
        done
        echo

        if confirm "Open selected extensions?"; then
            for name in "${selected_for_install[@]}"; do
                open_url "${extensions_map[$name]}"
                sleep 1
            done

            echo
            print_message "$GREEN" "All selected extensions have been opened in your browser."
            print_message "$YELLOW" "Note: You still need to complete the installation in the browser."
            read -rp "$(printf "\n%b:: Press ENTER to return to the main menu...%b" "$CYAN" "$NC")"
            clear
            return
        else
            print_message "$YELLOW" "Installation cancelled."
            sleep 1
        fi
    done
}

main() {
    while true; do
        clear
        local default_browser
        default_browser=$(detect_default_browser)

        print_message "$YELLOW" "Detected default browser: $default_browser"
        print_message "$YELLOW" "NOTE: Extensions will open in your default browser."
        print_message "$YELLOW" "Make sure your selection matches your default browser type."

        local options=("Chromium-based" "Firefox-based" "Exit")
        show_menu "Select your browser type" "${options[@]}"

        get_choice "${#options[@]}"
        local choice_index=$?
        local choice="${options[$((choice_index - 1))]}"

        case "$choice" in
            "Chromium-based")
                select_extensions "Chromium" chromium_extensions
                ;;
            "Firefox-based")
                select_extensions "Firefox" firefox_extensions
                ;;
            "Exit")
                return 0
                ;;
            *)
                print_message "$RED" "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

main
