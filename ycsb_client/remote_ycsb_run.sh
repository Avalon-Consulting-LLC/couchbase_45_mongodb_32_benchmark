#!/usr/bin/env sh

INVENTORY=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
hosts=`tail -n+3 $INVENTORY | grep ycsb | grep ansible_ssh_host | cut -d ' ' -f2 | cut -d '=' -f2`

# Local SSH key file
SSH_KEY=~/.ssh/cbcassandra.pem

# Remote files
YCSB_HOME=/opt/ycsb
LOGBACK_CONF=/vagrant/ycsb_scripts/logback.xml

# Modify for database & workload
dataset=cassandra-cql
workload=theon_workload
# Number of trials
RUNS=3

for host in "${hosts[@]}"; do
	scp -i $PEM_FILE "workloads/$workload" root@$host:/root
done

for host in "${hosts[@]}"; do
	ssh -i $SSH_KEY root@$host "rm -f theon_*_${dataset}_run.txt"
	for i in {1..$RUNS}; do
		ssh -i $SSH_KEY root@$host "$YCSB_HOME/bin/ycsb run $dataset -P $workload -jvm-args=\"-Dlogback.configurationFile=$LOGBACK_CONF\" &> theon_${i}_${dataset}_run.txt" &> /dev/null &
	done
done
