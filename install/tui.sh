#!/bin/sh

# Source: https://github.com/ChrisTitusTech/linutil

RC='\033[0m'
RED='\033[0;31m'

get_latest_release() {
  latest_release=$(curl -s https://api.github.com/repos/harilvfs/carch/releases | 
    grep -oP '"tag_name": "\K[^"]*' | 
    head -n 1)
  if [ -z "$latest_release" ]; then
    printf "%b\n" "Error fetching release data" >&2
    return 1
  fi
  printf "%b\n" "$latest_release"
}

redirect_to_latest_pre_release() {
  latest_release=$(get_latest_release)
  if [ -n "$latest_release" ]; then
    url="https://github.com/harilvfs/carch/releases/download/$latest_release/carch-tui"
  else
    printf "%b\n" 'Unable to determine latest pre-release version.' >&2
    printf "%b\n" "Using latest Full Release"
    url="https://github.com/harilvfs/carch/releases/latest/download/carch-tui"
  fi
  addArch
  printf "%b\n" "Using URL: $url"
}

check() {
    exit_code=$1
    message=$2

    if [ "$exit_code" -ne 0 ]; then
        printf "%b\n" "${RED}ERROR: $message${RC}"
        exit 1
    fi
}

addArch() {
    case "${arch}" in
        x86_64);;
        *) url="${url}-${arch}";;
    esac
}

findArch() {
    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        *) check 1 "Unsupported architecture"
    esac
}

findArch
redirect_to_latest_pre_release

TMPFILE=$(mktemp)
check $? "Creating the temporary file"

printf "%b\n" "Downloading carch-tui from $url"
curl -fsL "$url" -o "$TMPFILE"
check $? "Downloading carch-tui"

chmod +x "$TMPFILE"
check $? "Making carch-tui executable"

"$TMPFILE" "$@"
check $? "Executing carch-tui"

rm -f "$TMPFILE"
check $? "Deleting the temporary file"
