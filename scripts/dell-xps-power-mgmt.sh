#!/bin/sh

if [ -e /proc/acpi/bbswitch ]; then
    echo OFF > /proc/acpi/bbswitch
elif [ -e /proc/acpi/call ]; then
    echo '\\_SB.PCI0.PEG0.PEGP._OFF' > /proc/acpi/call
    if [ $(cat /proc/acpi/call) != '0x0called' ]; then
        echo "ACPI call failed!"
    fi
fi

echo deep > /sys/power/mem_sleep
