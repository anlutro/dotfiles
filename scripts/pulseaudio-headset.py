#!/usr/bin/env /home/andreas/code/dotfiles/.venv/bin/python

import pulsectl
pulse = pulsectl.Pulse(__file__)


def _find_preferred_port(resources, search_for):
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


def switch_source():
    pa_sources = pulse.source_list()
    preferred = _find_preferred_port(pa_sources, "headset-mic")
    if preferred:
        source, port = preferred
        print("switching source %s to port %s" % (source.name, port.name))
        pulse.source_port_set(source.index, port.name)
        print("setting default source %s" % (source.name,))
        pulse.default_set(source)


def switch_sink():
    pa_sinks = pulse.sink_list()
    preferred = _find_preferred_port(pa_sinks, ("headset", "headphone"))
    if preferred:
        sink, port = preferred
        print("switching sink %s to port %s" % (sink.name, port.name))
        pulse.sink_port_set(sink.index, port.name)
        print("setting default sink %s" % (sink.name,))
        pulse.default_set(sink)


if __name__ == "__main__":
    switch_sink()
    switch_source()
