f = open('.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory', 'r')
hosts_string = "( "

for line in f:
	items = line.split(" ")
	if line[0] != "#" and len(items) == 4:
		host = items[1].split("=")[1]
		hosts_string += "'%s' " % host

hosts_string += ")"
print(hosts_string)
