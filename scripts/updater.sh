#!/usr/bin/env bash

# For personal use only. Do not run this script yourself.

clear

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}"
if command -v figlet &>/dev/null; then
    figlet -f slant "Updater"
else
    echo "========== Version Updater =========="
fi
echo -e "${RESET}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" ]]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
else
    REPO_DIR="$(pwd)"
fi

OLD_VERSION=""
NEW_VERSION=""

check_repo() {
    if [ ! -d "$REPO_DIR/platforms/arch" ] || [ ! -d "$REPO_DIR/platforms/fedora" ]; then
        echo -e "${RED}Error: This doesn't appear to be the carch repository.${RESET}"
        echo -e "Current detected repo directory: $REPO_DIR"
        echo -e "Please run this script from the root of the carch repository or from the scripts directory."
        exit 1
    fi
}

detect_version() {
    if [ -f "$REPO_DIR/platforms/arch/install.sh" ]; then
        OLD_VERSION=$(grep "VERSION=" "$REPO_DIR/platforms/arch/install.sh" | cut -d'"' -f2)
        echo -e "${BLUE}Current version detected: ${BOLD}$OLD_VERSION${RESET}"
    else
        echo -e "${YELLOW}Warning: Could not detect current version from platforms/arch/install.sh${RESET}"
        echo -e "${YELLOW}Please enter the current version manually:${RESET}"
        read -p "> " OLD_VERSION
    fi
}

get_new_version() {
    echo -e "${BLUE}Please enter the new version number:${RESET}"
    read -p "> " NEW_VERSION
    
    if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Version must follow semantic versioning (e.g., 4.2.1)${RESET}"
        get_new_version
        return
    fi
    
    echo -e "\n${YELLOW}==== Update Summary ====${RESET}"
    echo -e "Current version: ${OLD_VERSION}"
    echo -e "New version:     ${BOLD}${NEW_VERSION}${RESET}"
    echo -e "${YELLOW}=========================${RESET}\n"
    
    echo -e "${BLUE}Do you want to proceed with these changes? (y/n)${RESET}"
    read -p "> " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Operation canceled. Exiting...${RESET}"
        exit 0
    fi
}

update_arch_install() {
    echo -e "${BLUE}Updating version in platforms/arch/install.sh...${RESET}"
    if [ -f "$REPO_DIR/platforms/arch/install.sh" ]; then
        sed -i "s/VERSION=\"$OLD_VERSION\"/VERSION=\"$NEW_VERSION\"/" "$REPO_DIR/platforms/arch/install.sh"
        echo -e "${GREEN}✓ Updated platforms/arch/install.sh${RESET}"
    else
        echo -e "${RED}Error: platforms/arch/install.sh not found!${RESET}"
    fi
}

update_fedora_install() {
    echo -e "${BLUE}Updating version in platforms/fedora/install.sh...${RESET}"
    if [ -f "$REPO_DIR/platforms/fedora/install.sh" ]; then
        sed -i "s/VERSION=\"$OLD_VERSION\"/VERSION=\"$NEW_VERSION\"/" "$REPO_DIR/platforms/fedora/install.sh"
        echo -e "${GREEN}✓ Updated platforms/fedora/install.sh${RESET}"
    else
        echo -e "${RED}Error: platforms/fedora/install.sh not found!${RESET}"
    fi
}

update_fedora_spec() {
    echo -e "${BLUE}Updating version in platforms/fedora/carch.spec...${RESET}"
    if [ -f "$REPO_DIR/platforms/fedora/carch.spec" ]; then
        VERSION_LINE_NUM=$(grep -n "^Version:" "$REPO_DIR/platforms/fedora/carch.spec" | cut -d: -f1)
        if [ -n "$VERSION_LINE_NUM" ]; then
            TMP_FILE=$(mktemp)
            awk -v line="$VERSION_LINE_NUM" -v new_ver="Version:        $NEW_VERSION" '
            NR == line {print new_ver; next}
            {print}
            ' "$REPO_DIR/platforms/fedora/carch.spec" > "$TMP_FILE"
            
            mv "$TMP_FILE" "$REPO_DIR/platforms/fedora/carch.spec"
            
            echo -e "${GREEN}✓ Updated version in platforms/fedora/carch.spec to $NEW_VERSION${RESET}"
        else
            echo -e "${RED}Error: Could not find Version line in platforms/fedora/carch.spec${RESET}"
        fi
        
        echo -e "${BLUE}Enter changelog entries (one per line). Type 'done' on a new line when finished:${RESET}"
        changelog_entries=()
        while true; do
            read -p "> " entry
            if [ "$entry" = "done" ]; then
                break
            fi
            changelog_entries+=("$entry")
        done
        
        CURRENT_DATE=$(date "+%a %b %d %Y")
        
        NEW_CHANGELOG="* $CURRENT_DATE RPM Builder <harilvfs@chalisehari.com.np> - $NEW_VERSION-1"
        
        CHANGELOG_CONTENT="$NEW_CHANGELOG"
        for entry in "${changelog_entries[@]}"; do
            CHANGELOG_CONTENT="$CHANGELOG_CONTENT\n- $entry"
        done
        
        CHANGELOG_LINE_NUM=$(grep -n "%changelog" "$REPO_DIR/platforms/fedora/carch.spec" | cut -d: -f1)
        if [ -n "$CHANGELOG_LINE_NUM" ]; then
            TMP_FILE=$(mktemp)
            
            CHANGELOG_LINE_NUM=$((CHANGELOG_LINE_NUM + 1))
            
            awk -v line="$CHANGELOG_LINE_NUM" -v changelog="$CHANGELOG_CONTENT" '
            NR == line {
                print changelog;
                print "";
                print;
                next;
            }
            {print}
            ' "$REPO_DIR/platforms/fedora/carch.spec" > "$TMP_FILE"
            
            mv "$TMP_FILE" "$REPO_DIR/platforms/fedora/carch.spec"
            echo -e "${GREEN}✓ Updated changelog in platforms/fedora/carch.spec${RESET}"
        else
            echo -e "${RED}Error: Could not find %changelog section in platforms/fedora/carch.spec${RESET}"
        fi
    else
        echo -e "${RED}Error: platforms/fedora/carch.spec not found!${RESET}"
    fi
}


update_man_page() {
    echo -e "${BLUE}Updating version in man/carch.1...${RESET}"
    if [ -f "$REPO_DIR/man/carch.1" ]; then
        MONTH=$(date "+%B %Y")
        sed -i "s/\.TH \"carch\" \"1\" \"[^\"]*\" \"Carch [^\"]*\"/.TH \"carch\" \"1\" \"$MONTH\" \"Carch $NEW_VERSION\"/" "$REPO_DIR/man/carch.1"
        echo -e "${GREEN}✓ Updated man/carch.1${RESET}"
    else
        echo -e "${RED}Error: man/carch.1 not found!${RESET}"
    fi
}

update_cargo_toml() {
    echo -e "${BLUE}Updating version in Cargo.toml...${RESET}"
    if [ -f "$REPO_DIR/Cargo.toml" ]; then
        sed -i "s/version = \"$OLD_VERSION\"/version = \"$NEW_VERSION\"/" "$REPO_DIR/Cargo.toml"
        echo -e "${GREEN}✓ Updated Cargo.toml${RESET}"
    else
        echo -e "${YELLOW}Searching for Cargo.toml in repository...${RESET}"
        CARGO_FILE=$(find "$REPO_DIR" -name "Cargo.toml" -type f | head -n 1)
        
        if [ -n "$CARGO_FILE" ]; then
            sed -i "s/version = \"$OLD_VERSION\"/version = \"$NEW_VERSION\"/" "$CARGO_FILE"
            echo -e "${GREEN}✓ Updated $CARGO_FILE${RESET}"
        else
            echo -e "${RED}Error: Cargo.toml not found in repository!${RESET}"
        fi
    fi
}

main() {
    echo -e "${BOLD}${BLUE}==== Carch Version Updater ====${RESET}"
    echo -e "${BLUE}Repository directory: ${REPO_DIR}${RESET}"
    
    check_repo
    detect_version
    get_new_version
    
    echo -e "${BLUE}Updating version from $OLD_VERSION to $NEW_VERSION...${RESET}"
    
    update_arch_install
    update_fedora_install
    update_fedora_spec
    update_man_page
    update_cargo_toml
    
    echo -e "\n${GREEN}${BOLD}Version update complete!${RESET}"
    echo -e "${GREEN}Updated from version $OLD_VERSION to $NEW_VERSION${RESET}"
    echo -e "\n${YELLOW}Please review the changes before committing:${RESET}"
    echo -e "  git diff"
    echo -e "\n${YELLOW}To commit the changes:${RESET}"
    echo -e "  git add ."
    echo -e "  git commit -m \"Bump version to $NEW_VERSION\""
    echo -e "  git tag -a v$NEW_VERSION -m \"Version $NEW_VERSION\""
    echo -e "  git push && git push --tags"
}

main "$@"
