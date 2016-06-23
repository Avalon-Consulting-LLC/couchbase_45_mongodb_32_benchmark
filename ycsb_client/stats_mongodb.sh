# 1
hosts=( 'ec2-54-68-220-30.us-west-2.compute.amazonaws.com' )

# 1 - 5
#hosts=( 'ec2-54-68-220-30.us-west-2.compute.amazonaws.com' 'ec2-54-68-197-108.us-west-2.compute.amazonaws.com' 'ec2-54-68-220-51.us-west-2.compute.amazonaws.com' 'ec2-52-11-202-117.us-west-2.compute.amazonaws.com' 'ec2-54-68-220-32.us-west-2.compute.amazonaws.com' )


for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "OVERALL.*Through" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*Average" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*80th" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "READ.*95th" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*Average" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*80th" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep "UPDATE.*95th" theon_*_mongodb_run.txt'
done
for i in "${hosts[@]}"; do
	ssh -i ../cb4mdb3benchmark.pem root@$i 'grep ".*Return" theon_*_mongodb_run.txt'
done
