# 1
hosts=( 'ec2-54-68-220-30.us-west-2.compute.amazonaws.com' )

# 1 - 5
#hosts=( 'ec2-54-68-220-30.us-west-2.compute.amazonaws.com' 'ec2-54-68-197-108.us-west-2.compute.amazonaws.com' 'ec2-54-68-220-51.us-west-2.compute.amazonaws.com' 'ec2-52-11-202-117.us-west-2.compute.amazonaws.com' 'ec2-54-68-220-32.us-west-2.compute.amazonaws.com' )

for i in "${hosts[@]}"; do
	scp -i ../cb4mdb3benchmark.pem workloads/theon_workload root@$i:/root
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'rm -f theon_*_mongodb_run.txt'
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run mongodb -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_1_mongodb_run.txt' &> /dev/null &
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run mongodb -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_2_mongodb_run.txt' &> /dev/null &
	ssh -i ../cb4mdb3benchmark.pem root@$i '/opt/ycsb-0.4.0-SNAPSHOT/bin/ycsb run mongodb -P theon_workload -jvm-args='-Dlogback.configurationFile=/vagrant/logback.xml' &> theon_3_mongodb_run.txt' &> /dev/null &
done
