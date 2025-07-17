#!/usr/bin/env bash

set -euo pipefail

if [[ "$(basename "$(pwd)")" == "scripts" ]]; then
    PROJECT_ROOT="$(cd .. && pwd)"
else
    PROJECT_ROOT="$(pwd)"
fi

check_trailing_whitespace() {
    local file="$1"
    if [ -r "$file" ]; then
        if grep -q '[[:space:]]\+$' "$file"; then
            echo "::error file=$file::Found trailing spaces in $file"
            echo "true" > /tmp/issues_found
        else
            echo "✓ No trailing spaces found in $file"
        fi
    else
        echo "::warning file=$file::Cannot read file: $file"
    fi
}

check_blank_lines() {
    local file="$1"
    if [ -r "$file" ]; then
        temp_file=$(mktemp)
        awk 'BEGIN { blank=0 }
            /^$/ { blank++; next }
            { if (blank>0) { print ""; blank=0 } print }
            END { }' "$file" > "$temp_file"
        if ! cmp -s "$file" "$temp_file"; then
            echo "::error file=$file::Found excessive blank lines in $file"
            echo "true" > /tmp/issues_found
        else
            echo "✓ No excessive blank lines found in $file"
        fi
        rm "$temp_file"
    else
        echo "::warning file=$file::Cannot read file: $file"
    fi
}

echo "Checking code style issues..."
echo "=================================================="
rm -f /tmp/issues_found

find "$PROJECT_ROOT" -type f -name "*.sh" -not -path "*/target/*" | while read -r file; do
    echo "Checking $file..."
    check_trailing_whitespace "$file"
    check_blank_lines "$file"
    echo "---------------------------------"
done

if [ -f "/tmp/issues_found" ] && [ "$(cat /tmp/issues_found)" = "true" ]; then
    echo "Code style issues were found. Please fix them and try again."
    rm -f /tmp/issues_found
    exit 1
else
    echo "All files passed code style checks."
    rm -f /tmp/issues_found
    exit 0
fi
