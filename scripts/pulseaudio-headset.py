#!/usr/bin/env python3

import subprocess

pa_sources = {}

cur_src = None
pactl_list_sources = subprocess.check_output(['pactl', 'list', 'sources'], encoding='utf-8').splitlines()
is_in_ports = False
for line in pactl_list_sources:
    if line.startswith('Source #'):
        cur_src = line[8:]
        pa_sources[cur_src] = {}
    elif line == '':
        cur_src = None

    if line.startswith('\tPorts:'):
        is_in_ports = True
    elif is_in_ports:
        if line.startswith('\t\t'):
            port, info = line.strip().split(': ', 1)
            if 'not available' not in info.lower():
                pa_sources[cur_src][port] = info
        else:
            is_in_ports = False

for source, ports in pa_sources.items():
    preferred = None
    for port in ports:
        if 'headset-mic' in port:
            preferred = source, port
            break
        preferred = source, port
    if preferred:
        print('switching source %s to port %s' % preferred)
        subprocess.check_call(['pactl', 'set-source-port', preferred[0], preferred[1]])

