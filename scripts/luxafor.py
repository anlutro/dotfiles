#!/usr/bin/env -S ${HOME}/code/dotfiles/.venv/bin/python
from __future__ import print_function
import sys
import os.path

sys.path.append(
    os.path.expanduser("~/.local/lib/python%d.%d/site-packages" % sys.version_info[:2])
)

import argparse

try:
    import usb.core
except ImportError:
    print(
        "module usb.core not found, try: pip%d install --user pyusb"
        % sys.version_info[0]
    )
    sys.exit(1)


def hex_to_rgb(value):  # http://stackoverflow.com/a/214657
    value = value.lstrip("#")
    lv = len(value)
    return tuple(int(value[i : i + lv // 3], 16) for i in range(0, lv, lv // 3))


class Luxafor:
    def __init__(self, dev):
        self.dev = dev

    def set_color(self, led, hex_color):
        red, green, blue = hex_to_rgb(hex_color)
        self.write(1, led, red, green, blue, 0, 0)

    def write(self, *values):
        self.dev.write(1, values)
        self.dev.write(1, values)

    def fade(self, led, hex_color, duration):
        red, green, blue = hex_to_rgb(hex_color)
        self.write(2, led, red, green, blue, duration, 0)

    def strobe(self, led, hex_color, delay, repeat):
        red, green, blue = hex_to_rgb(hex_color)
        self.write(3, led, red, green, blue, delay, 0, repeat)

    def wave(self, hex_color, pattern, delay, repeat):
        red, green, blue = hex_to_rgb(hex_color)
        self.write(4, pattern, red, green, blue, 0, delay, repeat)

    def pattern(self, pattern, delay):
        self.write(6, pattern, delay, 0, 0, 0, 0)

    def off(self):
        self.write(6, 0, 0, 0, 0, 0)


def get_device():
    device = usb.core.find(idVendor=0x04D8, idProduct=0xF372)
    if not device:
        print("Could not find device! Is the Luxafor connected?")
        sys.exit(1)
    try:
        device.detach_kernel_driver(0)
    except usb.core.USBError:
        pass
    device.set_configuration()
    return device


COLORS = {
    "red": "ff0000",
    "green": "00ff00",
    "blue": "0000ff",
    "purple": "ff00ff",
    "yellow": "ff9900",
    "white": "ffffff",
    "off": "000000",
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--led", type=int, default=1)
    subparsers = parser.add_subparsers(dest="action")

    off_parser = subparsers.add_parser("off")

    color_parser = subparsers.add_parser("color", aliases=("c",))
    color_parser.add_argument("color", type=str)

    fade_parser = subparsers.add_parser("fade-to-color", aliases=("f",))
    fade_parser.add_argument("color", type=str)
    fade_parser.add_argument("-d", "--duration", type=int, default=25)

    strobe_parser = subparsers.add_parser("strobe", aliases=("s",))
    strobe_parser.add_argument("color", type=str)
    strobe_parser.add_argument("-d", "--delay", type=int, default=25)
    strobe_parser.add_argument("-r", "--repeat", type=int, default=100)

    wave_parser = subparsers.add_parser("wave", aliases=("w",))
    wave_parser.add_argument("color", type=str)
    wave_parser.add_argument("pattern", type=int)
    wave_parser.add_argument("-d", "--delay", type=int, default=25)
    wave_parser.add_argument("-r", "--repeat", type=int, default=100)

    pattern_parser = subparsers.add_parser("pattern", aliases=("p",))
    pattern_parser.add_argument("pattern", type=int)
    pattern_parser.add_argument("-d", "--delay", type=int, default=25)

    args = parser.parse_args()

    luxafor = Luxafor(get_device())

    if "color" in args and args.color in COLORS:
        args.color = COLORS[args.color]

    if args.action == "off":
        luxafor.set_color(args.led, "#000000")
    elif args.action in ("color", "c"):
        luxafor.set_color(args.led, args.color)
    elif args.action in ("fade-to-color", "f"):
        luxafor.fade(args.led, args.color, args.duration)
    elif args.action in ("strobe", "s"):
        luxafor.strobe(args.led, args.color, args.delay, args.repeat)
    elif args.action in ("wave", "w"):
        luxafor.wave(args.color, args.pattern, args.delay, args.repeat)
    elif args.action in ("pattern", "p"):
        luxafor.pattern(args.pattern, args.delay)
    else:
        print("Unknown action: %r" % args.action)
        sys.exit(1)


if __name__ == "__main__":
    main()
