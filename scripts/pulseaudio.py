#!/usr/bin/env -S ${HOME}/code/dotfiles/.venv/bin/python

import argparse
import pulsectl
import sys

pulse = pulsectl.Pulse(__file__)


def get_all_card_profiles():
    for card in pulse.card_list():
        for profile in card.profile_list:
            yield card, profile


def find_hdmi_card_profiles(card_profiles, surround=False, surround71=False):
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


def find_bluetooth_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if 'bluez' in card.name:
            yield card, profile


def find_default_card_profiles(card_profiles):
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo+input:analog-stereo':
            yield card, profile
    for card, profile in card_profiles:
        if profile.name == 'output:analog-stereo':
            yield card, profile


class EmptyPort:
    name = 'empty-port'
    available = 'yes'
    priority = 0


def find_preferred_port(resources, search_for):
    if isinstance(search_for, str):
        search_for = (search_for,)

    # flatten the resources->ports structure to simplify iterating/filtering
    resources_ports = []
    for resource in resources:
        # bluetooth devices don't seem to have a port
        if not resource.port_list:
            resource.port_list = [EmptyPort()]
        for port in resource.port_list:
            if port.available == 'no':
                continue
            resources_ports.append((resource, port))

    # if any of the items match the search, sort those by priority and pick
    # the top one. if no matches, just pick the highest priority one.
    searched_resources = []
    for resource, port in resources_ports:
        if any(s in resource.name for s in search_for) or any(s in port.name for s in search_for):
            searched_resources.append((resource, port))
    if searched_resources:
        resources_ports = searched_resources
    else:
        print(f'WARNING: no resources matched {search_for=!r} - will just pick first available default resource')

    preferred_resource, preferred_port = None, None
    for resource, port in resources_ports:
        if preferred_port is None or port.priority > preferred_port.priority:
            preferred_resource, preferred_port = resource, port
    return preferred_resource, preferred_port


def switch_source(preferred_patterns):
    pa_sources = pulse.source_list()
    source, port = find_preferred_port(pa_sources, preferred_patterns)
    if source and port:
        if not isinstance(port, EmptyPort):
            print("switching source %s to port %s" % (source.name, port.name))
            pulse.source_port_set(source.index, port.name)
        print("setting default source %s" % (source.name,))
        pulse.default_set(source)
        return source
    else:
        print("no source ports found!")


def switch_sink(preferred_patterns):
    pa_sinks = pulse.sink_list()
    sink, port = find_preferred_port(pa_sinks, preferred_patterns)
    if sink and port:
        # conditional here shouldn't be necessary but switching sink ports on
        # bluetooth crashes
        if sink.port_active.name != port.name:
            print("switching sink %s to port %s" % (sink.name, port.name))
            pulse.sink_port_set(sink.index, port.name)
        print("setting default sink %s" % (sink.name,))
        pulse.default_set(sink)
        return sink
    else:
        print("no sink ports found!")


def arg_to_float(arg):
    if ',' in arg:
        arg = arg.replace(',', '.')
    if '.' in arg:
        return float(arg)
    if arg.endswith('%'):
        return float(arg[:-1]) / 100


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--hdmi', action='store_true', help='use HDMI audio')
    p.add_argument('--surround', action='store_true', help='prefer surround over stereo')
    p.add_argument('--surround71', action='store_true', help='prefer 7.1 surround over stereo')
    p.add_argument('-bt', '--bluetooth', action='store_true', help='prefer bluetooth devices')
    p.add_argument('--source-volume', type=arg_to_float, help='set source volume')
    p.add_argument('--preferred-sink', nargs='*')
    p.add_argument('--preferred-source', nargs='*')
    args = p.parse_args()

    all_profiles = sorted(get_all_card_profiles(), key=lambda x: -x[1].priority)

    if args.hdmi:
        cards = list(find_hdmi_card_profiles(all_profiles, surround=args.surround, surround71=args.surround71))
        if not cards:
            print('no active HDMI outputs found!')
            return 1
    elif args.bluetooth:
        cards = list(find_bluetooth_card_profiles(all_profiles))
        if not cards:
            print('no active Bluetooth devices found!')
            return 1
    else:
        cards = list(find_default_card_profiles(all_profiles))

    if not cards:
        print('no cards/profiles found!')
        return

    card, profile = cards[0]
    print('setting card:', card)
    print('setting profile:', profile)
    pulse.card_profile_set(card, profile)

    source = None
    # TODO: why not args.hdmi?
    if not args.hdmi:
        if not args.preferred_source:
            args.preferred_source = ("bluez", "bluetooth") if args.bluetooth else ("headset-mic")
        source = switch_source(args.preferred_source)
    if source and args.source_volume:
        print('setting source volume to', args.source_volume)
        pulse.volume_set_all_chans(source, args.source_volume)

    # TODO: why not args.hdmi?
    # TODO: bluetooth causes pulsectl.pulsectl.PulseOperationFailed: 3
    if not args.hdmi:
        if not args.preferred_sink:
            args.preferred_sink = ("bluez", "bluetooth") if args.bluetooth else ("headphone")
        switch_sink(args.preferred_sink)


if __name__ == '__main__':
    sys.exit(main())
