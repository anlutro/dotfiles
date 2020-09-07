#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import pulsectl
import sys

pulse = pulsectl.Pulse(__file__)


def get_all_card_profiles():
    for card in pulse.card_list():
        for profile in card.profile_list:
            yield card, profile


def find_hdmi_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if any((
            profile.available == 0,
            'hdmi' not in profile.name,
            # for some reason, connected hdmi cables don't have +input - maybe
            # because hdmi *can* have audio input, but it doesn't actually
            # exist in real life?
            '+input' in profile.name,
        )):
            continue
        if '--surround71' in sys.argv:
            if 'surround71' not in profile.name:
                continue
        elif '--surround' in sys.argv:
            if 'surround' not in profile.name:
                continue
        else:
            if 'surround' in profile.name:
                continue
        yield card, profile


def find_default_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo+input:analog-stereo':
            yield card, profile
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo':
            yield card, profile


def first_or_none(sequence):
    for item in sequence:
        return item
    return None


def main():
    all_profiles = sorted(get_all_card_profiles(), key=lambda x: x[1].priority)
    card, profile = (
        first_or_none(find_hdmi_card_profiles(all_profiles))
        or first_or_none(find_default_card_profiles(all_profiles))
    )
    print(card)
    print(profile)
    pulse.card_profile_set(card, profile)


if __name__ == '__main__':
    main()
