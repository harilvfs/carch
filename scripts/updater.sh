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
    if [ ! -d "$REPO_DIR/scripts" ] || [ ! -d "$REPO_DIR/scripts" ]; then
        echo -e "${RED}Error: This doesn't appear to be the carch repository.${RESET}"
        echo -e "Current detected repo directory: $REPO_DIR"
        echo -e "Please run this script from the root of the carch repository or from the scripts directory."
        exit 1
    fi
}

detect_version() {
    if [ -f "$REPO_DIR/Cargo.toml" ]; then
        OLD_VERSION=$(grep '^version = ' "$REPO_DIR/Cargo.toml" | head -n 1 | cut -d'"' -f2)
        echo -e "${BLUE}Current version detected: ${BOLD}$OLD_VERSION${RESET}"
    else
        echo -e "${YELLOW}Warning: Could not detect current version from Cargo.toml${RESET}"
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
