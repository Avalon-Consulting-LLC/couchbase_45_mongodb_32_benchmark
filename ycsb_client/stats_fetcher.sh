#!/usr/bin/env sh

INVENTORY=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
hosts=`tail -n+3 $INVENTORY | grep ycsb | grep ansible_ssh_host | cut -d ' ' -f2 | cut -d '=' -f2`

# Local SSH key file
SSH_KEY=~/.ssh/cbcassandra.pem

# Modify for database & workload
dataset=cassandra-cql
workload=theon

STATS="${workload}_*_${dataset}_run.txt"
values=( "OVERALL.*Through" "READ.*Average" "READ.*80th" "READ.*95th" "UPDATE.*Average" "UPDATE.*80th" "UPDATE.*95th" )

for host in "${hosts[@]}"; do
	for v in "${values[@]}"; do
		ssh -i $SSH_KEY root@$host "grep \"$v\" $STATS"
	done
done

# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*Average" theon_*_couchbase_run.txt'
# done
# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*80th" theon_*_couchbase_run.txt'
# done
# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*95th" theon_*_couchbase_run.txt'
# done
# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*Average" theon_*_couchbase_run.txt'
# done
# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*80th" theon_*_couchbase_run.txt'
# done
# for i in $( tail -n+3 .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory | cut -d ' ' -f2 | cut -d '=' -f2 ); do
# 	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*95th" theon_*_couchbase_run.txt'
# done
