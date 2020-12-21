#!/bin/sh

out=$(findmnt --df --noheadings "${BLOCK_INSTANCE:-/}")
if [ -z "$out" ]; then
    exit 1
fi
echo "$out" | awk '{
    free=$5
    pct=$6
    name=$7
    exit 0
}
END {
    print name, free " (" pct ")"
    print name, free " (" pct ")"
    gsub(/%$/, "", pct)
    pct = pct + 0
    if (pct > 95) {
        print "#ff0000"
    }
    else if (pct > 85) {
        # yellow -> red -- ffff00 -> ff0000
        hexint = 255 - (pct - 85) / 10 * 255
        printf "#ff%02x00\n", hexint
    }
    else if (pct > 75) {
        # white -> yellow -- ffffff -> ffff00
        hexint = 255 - (pct - 75) / 10 * 255
        printf "#ffff%02x\n", hexint
    }
    else {
        print "#ffffff"
    }
}'
