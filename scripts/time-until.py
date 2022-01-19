#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import argparse
import datetime
import dateutil.parser


def parse_dt(val):
    return dateutil.parser.parse(val)


def get_time_until(dt, unit=None):
    now = datetime.datetime.now(dt.tzinfo)
    delta = dt - now
    if unit is not None:
        unit = unit.strip().lower()
        if unit[0] == "d":
            return f"{delta.days} days"
        elif unit[0] == "h":
            delta = str(int((delta.days * 24) + (delta.seconds / 3600))) + " hours"
        elif unit in ("mins", "minutes"):
            delta = str(int((delta.days * 24 * 60) + (delta.seconds / 60))) + " minutes"
    return delta


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--unit")
    parser.add_argument("-t", "--template", default="Time until {time}: {remaining}")
    parser.add_argument("datetime", type=parse_dt)
    args = parser.parse_args()
    print(
        args.template.format(
            time=args.datetime,
            remaining=get_time_until(args.datetime, unit=args.unit),
        )
    )


if __name__ == "__main__":
    main()
