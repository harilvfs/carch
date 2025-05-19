#!/usr/bin/env bash

# btw, this is for my personal use, but if you want, you may also use it.
# basically, it removes white spaces and blank lines in shell scripts.

if [[ "$(basename "$(pwd)")" == "scripts" ]]; then
    PROJECT_ROOT="$(cd .. && pwd)"
else
    PROJECT_ROOT="$(pwd)"
fi

remove_trailing_whitespace() {
    local file="$1"
    local show_diff="$2"
    if [ -r "$file" ]; then
        if grep -q '[[:space:]]\+$' "$file"; then
            echo "Found trailing spaces in: $file"
            if [ "$show_diff" = true ]; then
                cp "$file" "${file}.bak"
            fi
            temp_file=$(mktemp)
            sed 's/[[:space:]]\+$//' "$file" > "$temp_file"
            cp "$temp_file" "$file"
            rm "$temp_file"
            if [ "$show_diff" = true ]; then
                echo "--- Diff for trailing whitespace removal ---"
                diff -u "${file}.bak" "$file" || true
                rm "${file}.bak"
                echo "--- End of diff ---"
            fi
            echo "✓ Trailing spaces removed from $file"
        else
            echo "✓ No trailing spaces found in $file"
        fi
    else
        echo "Cannot read file: $file"
        return 1
    fi
}

remove_trailing_blank_lines() {
    local file="$1"
    local show_diff="$2"
    if [ -r "$file" ]; then
        original_size=$(stat -c %s "$file")
        if [ "$show_diff" = true ]; then
            cp "$file" "${file}.bak"
        fi
        temp_file=$(mktemp)
        awk 'BEGIN { blank=0 }
             /^$/ { blank++; next }
             { if (blank>0) { print ""; blank=0 } print }
             END { }' "$file" > "$temp_file"
        cp "$temp_file" "$file"
        new_size=$(stat -c %s "$file")
        rm "$temp_file"
        if [ "$original_size" -ne "$new_size" ]; then
            if [ "$show_diff" = true ]; then
                echo "--- Diff for trailing blank lines removal ---"
                diff -u "${file}.bak" "$file" || true
                rm "${file}.bak"
                echo "--- End of diff ---"
            fi
            echo "✓ Blank lines removed $file"
        else
            if [ "$show_diff" = true ]; then
                rm "${file}.bak"
            fi
            echo "✓ No blank lines found $file"
        fi
    else
        echo "Cannot read file: $file"
        return 1
    fi
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "cleanup shell script whitespace & blank-lines"
    echo
    echo "Options:"
    echo "  -w, --whitespace    Remove only trailing whitespace"
    echo "  -b, --blank-lines   Remove only trailing blank lines"
    echo "  -d, --diff          Show diff of changes made"
    echo "  -h, --help          Show this help message"
    echo
    echo "If neither -w nor -b is specified, both cleanups will be done."
}

DO_WHITESPACE=false
DO_BLANKLINES=false
SHOW_DIFF=false

if [ $# -eq 0 ]; then
    DO_WHITESPACE=true
    DO_BLANKLINES=true
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -w|--whitespace)
            DO_WHITESPACE=true
            shift
            ;;
        -b|--blank-lines)
            DO_BLANKLINES=true
            shift
            ;;
        -d|--diff)
            SHOW_DIFF=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

if [ "$DO_WHITESPACE" = false ] && [ "$DO_BLANKLINES" = false ]; then
    DO_WHITESPACE=true
    DO_BLANKLINES=true
fi

find "$PROJECT_ROOT" -type f -name "*.sh" -not -path "*/target/*" | while read -r file; do
    if [ -r "$file" ]; then
        echo "Processing $file..."
        if [ "$DO_WHITESPACE" = true ]; then
            remove_trailing_whitespace "$file" "$SHOW_DIFF"
        fi
        if [ "$DO_BLANKLINES" = true ]; then
            remove_trailing_blank_lines "$file" "$SHOW_DIFF"
        fi
        echo "---------------------------------"
    else
        echo "Cannot read file: $file"
    fi
done

echo "completed."
