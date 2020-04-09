#!/usr/bin/env python

import pulsectl
pulse = pulsectl.Pulse(__file__)


def get_all_card_profiles():
    for card in pulse.card_list():
        for profile in card.profile_list:
            yield card, profile


def find_hdmi_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if profile.available == 0:
            continue
        if 'hdmi' not in profile.name:
            continue
        # for some reason, connected hdmi cables don't have +input - maybe
        # because hdmi *can* have audio input, but it doesn't actually exist
        # in real life?
        if '+input' in profile.name:
            continue
        yield card, profile


def find_default_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo+input:analog-stereo':
            yield card, profile
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo':
            yield card, profile


def first_or_none(lst):
    for item in lst:
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
