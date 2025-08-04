#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

# Options for shfmt:
# -i 4:  indent with 4 spaces
# -ci:   indent case statements
# -sr:   space after redirect operators
# -kp:   keep column alignment for & and &&
# -w:    write changes back to the file

echo "Formatting shell scripts..."

find . -type f -name "*.sh" | grep -v './scripts/modules/Browser/Extensions.sh' | xargs shfmt -i 4 -ci -sr -kp -w

echo "Formatting complete."
