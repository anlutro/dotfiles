#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import pulsectl
pulse = pulsectl.Pulse(__file__)


def _find_preferred_port(resources, search_for):
    if isinstance(search_for, str):
        search_for = (search_for,)
    preferred = None
    for resource in resources:
        for port in resource.port_list:
            if port.available == 'no':
                continue
            if any(s in port.name for s in search_for):
                preferred = resource, port
                break
            preferred = resource, port
    return preferred


def switch_source():
    pa_sources = pulse.source_list()
    preferred = _find_preferred_port(pa_sources, "headset-mic")
    if preferred:
        source, port = preferred
        print("switching source %s to port %s" % (source.name, port.name))
        pulse.source_port_set(source.index, port.name)


def switch_sink():
    pa_sinks = pulse.sink_list()
    preferred = _find_preferred_port(pa_sinks, ("headset", "headphone"))
    if preferred:
        sink, port = preferred
        print("switching sink %s to port %s" % (sink.name, port.name))
        pulse.sink_port_set(sink.index, port.name)


if __name__ == "__main__":
    switch_sink()
    switch_source()
