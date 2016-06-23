for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "OVERALL.*Through" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*Average" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*80th" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*95th" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*Average" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*80th" theon_*_couchbase_run.txt'
done
for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*95th" theon_*_couchbase_run.txt'
done
