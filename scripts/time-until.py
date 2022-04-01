#!/usr/bin/env -S ${HOME}/code/dotfiles/.venv/bin/python

import argparse
import datetime
import dateutil.parser


def parse_dt(val):
    return dateutil.parser.parse(val)


def get_time_until(dt, unit=None):
    now = datetime.datetime.now(dt.tzinfo)
    delta = dt - now
    delta_parts = []
    if unit is not None:
        unit = unit.strip().lower()
    if not unit or unit[0] == "d":
        delta_parts.append(f"{delta.days} days")
        delta = delta - datetime.timedelta(days=delta.days)
    if not unit or unit[0] == "h":
        hours = int(delta.seconds / 3600)
        if hours > 0 or (unit and unit[0] == "h"):
            delta_parts.append(
                str(int((delta.days * 24) + hours)) + " hours"
            )
            delta = delta - datetime.timedelta(hours=hours)
    if not unit or unit[0] == "m":
        minutes = int(delta.seconds / 60)
        if minutes > 0 or (unit and unit[0] == "m"):
            delta_parts.append(
                str(int((delta.days * 24 * 60) + minutes)) + " minutes"
            )
            delta = delta - datetime.timedelta(minutes=minutes)
    return ", ".join(delta_parts)


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
