#!/bin/sh

: ${SEVERITY:=warning}

# we want to find scripts with a shell-like shebang
# AND files with the .sh extension
{
    find ./configs ./scripts -type f -exec awk 'FNR == 1 && /^#!.*sh/{print FILENAME}' {} +
    find ./configs ./scripts -type f -name '*.sh'
} | sort | uniq | xargs -r shellcheck --shell=bash --severity "$SEVERITY"
