#!/usr/bin/env python

from __future__ import print_function
import argparse
import json
import os
import os.path
import subprocess
import sys


def exit_err(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def get_vagrant_index():
    path = os.path.expanduser('~/.vagrant.d/data/machine-index/index')
    with open(path) as filehandle:
        return json.load(filehandle)


def find_relevant_machines(index_data, root_dir):
    for machine in index_data['machines'].values():
        if machine['state'] == 'running' and machine['vagrantfile_path'] == root_dir:
            yield machine


def get_vagrant_file(machine, filename):
    return os.path.join(
        machine['local_data_path'], 'machines', machine['name'],
        machine['provider'], filename,
    )


def get_vagrant_privkey(machine):
    return get_vagrant_file(machine, 'private_key')


def get_machine_ssh_info(machine):
    # this works if the virtualbox machine has guest additions installed
    vbox_id_path = get_vagrant_file(machine, 'id')
    with open(vbox_id_path) as filehandle:
        vbox_id = filehandle.read().decode()
    vbox_out = subprocess.check_output([
        'vboxmanage', 'guestproperty', 'get', vbox_id,
        '/VirtualBox/GuestInfo/Net/1/V4/IP',
    ]).strip()
    if vbox_out != 'No value set!':
        return vbox_out.split()[1], None

    # fall back to the forwarded port that vagrant uses
    ssh_conf = subprocess.check_output(['vagrant', 'ssh-config', machine['name']])
    ssh_conf_lines = (line.split(None, 1) for line in ssh_conf.splitlines() if line)
    ssh_config_dict = {key.lower(): val for key, val in ssh_conf_lines}
    return ssh_config_dict['hostname'], ssh_config_dict['port']


def get_machine_group_data(machine, ansible_vars=None):
    ansible_vars = ansible_vars or {}
    ansible_vars['ansible_ssh_private_key_file'] = get_vagrant_privkey(machine)
    ip, port = get_machine_ssh_info(machine)

    # TODO: change ansible_ssh_ to ansible_ when upgrading to ansible 2
    ansible_vars['ansible_ssh_host'] = ip
    if port:
        ansible_vars['ansible_ssh_port'] = port

    return {
        'hosts': [ip],
        'vars': ansible_vars,
    }


def get_inventory_data(root_dir):
    ssh_args = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    data = {
        'all': {
            'vars': {
                'ansible_user': 'root',
                'ansible_ssh_common_args': ssh_args,
            },
        },
        'vagrant': {'children': []},
    }

    index_data = get_vagrant_index()
    for machine in find_relevant_machines(index_data, root_dir):
        data[machine['name']] = get_machine_group_data(machine)
        data['vagrant']['children'].append(machine['name'])

    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--root-dir', default=os.getcwd())
    args = parser.parse_args()

    data = get_inventory_data(args.root_dir)
    print(json.dumps(data))

if __name__ == '__main__':
    main()
