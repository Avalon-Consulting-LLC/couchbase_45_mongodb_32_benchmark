# 1
hosts=( 'ec2-52-89-27-209.us-west-2.compute.amazonaws.com' )


for i in "${hosts[@]}"; do
	scp -i ../cb4mdb3benchmark.pem workloads/theon_workload root@$i:/root
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'rm -f theon_*_couchbase_run.txt'
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run couchbase220 -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_1_couchbase_run.txt' &> /dev/null &
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run couchbase220 -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_2_couchbase_run.txt' &> /dev/null &
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run couchbase220 -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_3_couchbase_run.txt' &> /dev/null &
done
