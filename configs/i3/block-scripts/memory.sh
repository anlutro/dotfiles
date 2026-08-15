#!/bin/bash

awk '
/^MemTotal:/ {
    mem_total=$2
}
/^MemFree:/ {
    mem_free=$2
}
/^Buffers:/ {
    mem_free+=$2
}
/^Cached:/ {
    mem_free+=$2
}
END {
    free=mem_free/1024/1024
    used=(mem_total-mem_free)/1024/1024
    total=mem_total/1024/1024

    pct=0
    if (total > 0) {
        pct=used/total*100
    }

    # full text
    printf("Memory %.1fG/%.1fG (%.f%%)\n", used, total, pct)
    # short text
    printf("%.f%%\n", pct)

    # color
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
}
' /proc/meminfo
