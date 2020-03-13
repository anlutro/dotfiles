#!/usr/bin/env python3

import subprocess


def _get_pa_resources(resource):
    line_prefix = resource.title() + ' #'
    line_prefix_len = len(line_prefix)
    ret = {}
    cur = None
    is_in_ports = False
    pactl_list = subprocess.check_output(['pactl', 'list', resource+'s'], encoding='utf-8').splitlines()

    for line in pactl_list:
        # print(repr(line), line_prefix, line_prefix_len)
        if line.startswith(line_prefix):
            cur = line[line_prefix_len:]
            ret[cur] = {}
        elif line == '':
            cur = None

        if line.startswith('\tPorts:'):
            is_in_ports = True
        elif is_in_ports:
            if line.startswith('\t\t'):
                port, info = line.strip().split(': ', 1)
                if 'not available' not in info.lower():
                    ret[cur][port] = info
            else:
                is_in_ports = False

    return ret


def _find_preferred_port(resources, search_for):
    if isinstance(search_for, str):
        search_for = (search_for,)
    preferred = None
    for source, ports in resources.items():
        for port in ports:
            if any(s in port for s in search_for):
                preferred = source, port
                break
            preferred = source, port
    return preferred


def switch_source():
    pa_sources = _get_pa_resources('source')
    preferred = _find_preferred_port(pa_sources, 'headset-mic')
    if preferred:
        print('switching source %s to port %s' % preferred)
        subprocess.check_call(['pactl', 'set-source-port', preferred[0], preferred[1]])


def switch_sink():
    pa_sinks = _get_pa_resources('sink')
    preferred = _find_preferred_port(pa_sinks, ('headset', 'headphone'))
    if preferred:
        print('switching sink %s to port %s' % preferred)
        subprocess.check_call(['pactl', 'set-sink-port', preferred[0], preferred[1]])


if __name__ == '__main__':
    switch_sink()
    switch_source()
