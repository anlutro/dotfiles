#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import argparse
import pulsectl
import sys

pulse = pulsectl.Pulse(__file__)


def get_all_card_profiles():
    for card in pulse.card_list():
        for profile in card.profile_list:
            yield card, profile


def find_hdmi_card_profiles(card_profiles, bluetooth=False, surround=False, surround71=False):
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
        if bluetooth:
            if 'bluez' not in profile.name:
                continue
        elif surround71:
            if 'surround71' not in profile.name:
                continue
        elif surround:
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


def find_preferred_port(resources, search_for):
    if isinstance(search_for, str):
        search_for = (search_for,)

    # flatten the resources->ports structure to simplify iterating/filtering
    resources_ports = []
    for resource in resources:
        for port in resource.port_list:
            if port.available == 'no':
                continue
            resources_ports.append((resource, port))

    # if any of the items match the search, sort those by priority and pick
    # the top one. if no matches, just pick the highest priority one.
    searched_resources = []
    for resource, port in resources_ports:
        if any(s in port.name for s in search_for):
            searched_resources.append((resource, port))
    if searched_resources:
        resources_ports = searched_resources

    preferred_resource, preferred_port = None, None
    for resource, port in resources_ports:
        if preferred_port is None or port.priority > preferred_port.priority:
            preferred_resource, preferred_port = resource, port
    return preferred_resource, preferred_port


def switch_source(bluetooth=False):
    pa_sources = pulse.source_list()
    source, port = find_preferred_port(pa_sources, "bluez" if bluetooth else "headset-mic")
    if source and port:
        print("switching source %s to port %s" % (source.name, port.name))
        pulse.source_port_set(source.index, port.name)
        print("setting default source %s" % (source.name,))
        pulse.default_set(source)
    else:
        print("no source ports found!")


def switch_sink():
    pa_sinks = pulse.sink_list()
    sink, port = find_preferred_port(pa_sinks, ("headset", "headphone"))
    if sink and port:
        print("switching sink %s to port %s" % (sink.name, port.name))
        pulse.sink_port_set(sink.index, port.name)
        print("setting default sink %s" % (sink.name,))
        pulse.default_set(sink)
    else:
        print("no sink ports found!")


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--hdmi', action='store_true', help='use HDMI audio')
    p.add_argument('--surround', action='store_true', help='prefer surround over stereo')
    p.add_argument('--surround71', action='store_true', help='prefer 7.1 surround over stereo')
    p.add_argument('--bluetooth', action='store_true', help='prefer bluetooth devices')
    args = p.parse_args()

    all_profiles = sorted(get_all_card_profiles(), key=lambda x: x[1].priority)

    if args.hdmi:
        cards = list(find_hdmi_card_profiles(all_profiles, bluetooth=args.bluetooth, surround=args.surround, surround71=args.surround71))
        if not cards:
            print('no active HDMI outputs found!')
            return 1
    else:
        cards = list(find_default_card_profiles(all_profiles))

    card, profile = cards[0]
    print('setting card:', card)
    print('setting profile:', profile)
    pulse.card_profile_set(card, profile)

    if not args.hdmi and not args.bluetooth:
        switch_source(bluetooth=args.bluetooth)

    # TODO: bluetooth causes pulsectl.pulsectl.PulseOperationFailed: 3
    if not args.hdmi and not args.bluetooth:
        switch_sink()


if __name__ == '__main__':
    sys.exit(main())
