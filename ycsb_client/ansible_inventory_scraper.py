#!/usr/bin/env python
# coding=utf8

import re

inventory = '.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory'

regex = r"ansible_ssh_host=([^\s]+)"
with open(inventory) as f:
	hosts = []
	for line in f:
		ssh_hosts = re.findall(regex, line)
		if ssh_hosts:
			hosts.append(ssh_hosts[0])

print ( "({})".format( " ".join( "'{}'".format(host) for host in hosts ) ) )
