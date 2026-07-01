#!/bin/sh

cd "$(dirname "$0")" || exit 1

echo "Running shellcheck on shell scripts..."

find . -type f -name "*.sh" \
    -not -path "./target/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" -print0 |
    xargs -0 shellcheck --severity=warning

echo "Shellcheck complete."
