# YCSB - Complete Steps for Testing


1. clone this repository

1. Modify your "private_settings.yml" and update any values that may need to be changed. (i.e. Pointer to your .pem file, AWS keys, regions, subnets, etc.)

1. `cd ycsb_client`

1. _MongoDB testing only:_ All of the MongoDB Sservers must be configured and running. Run the command below to get the YCSB Vagrantfile mongos_config: value.

	```../mongodb/getMongoDBServerPublicNamesList.sh -r us-west-2 -s server -n 3 -p 27020```

	Where:
	
	* -r is the AWS region where the server instances are located
	* -s is the MongoDB Server name prefix minus the sequence number (server1, server2, server3, etc.)
	* -n is the number of server instances 
	* -p Port that MongoDB is running on it's Server. Most likely 27020

1. _MongoDB testing only:_ Modify "Vagrantfile" and update the "mongos_config:" value using the result string from the command above.

1. Modify "Vagrantfile" and update the "machines = 8" value to the number of YCSB clients required.

1. ```vagrant up --provider=aws```  This may take some time to complete.

1. From the ECS Management Console, select all the YCSB servers. Right click and select Instance State->Stop

1. Once all the servers have stopped, run these commands from a terminal:
	
    ```
../enableEnhancedNetworking.sh -r us-west-2 -p ycsb -s 1 -n 14
	Where -r is the AWS region where the server instances are located
	      -s is the server name prefix minus the sequence number (ycsb1, ycsb2, etc.)
	      -n is the number of server instances 
    ```

1. From the ECS Management Console, select all the YCSB servers. Right click and select Instance State->Start

1. ```vagrant ssh ycsb1```

1. Run iperf3 Test on each YCSB machine one at a time. Start the iperf3 server on one DB server: ```iperf3 --server```.

    *	*MongoDB*
        * `/opt/iperf3YCSBtoServerTest.sh -r us-west-2 -s server -n 9`

    * *Couchbase*
        * `/opt/iperf3YCSBtoServerTest.sh -r us-west-2 -s data -n 9`


    **NOTE:** The expected Bandwidth should be pretty close to 10 Gbits/sec.

1. Check for the core-io-1.3.0-SNAPSHOT.jar

    ```
ls -las /opt/ycsb-0.10.0-SNAPSHOT/couchbase2-binding/lib
```
    Should see : core-io-1.3.0-SNAPSHOT.jar




## Workload A

### Load Data for YCSB workloada test from YCSB Server 1

```
cd /opt/ycsb-0.10.0-SNAPSHOT
export workload=workloada
export workloadHost=<<FIRSTDBSERVERIPADDRESS>>
./bin/ycsb load couchbase2 -s -threads 35 -P workloads/${workload} -p couchbase.host=${workloadHost}
```

### Running the YCSB workloada tests

**NOTE:** Before running the test do a search and replace for 52.41.74.211 and replace it with the public IP address of the first server in your new couchbase cluster.

For each group below after doing the search and replace mention above you paste the group of commands on each required YCSB server. 
For this benchmark, we performed 3 separate runs. For example, to test the first couchbase node, you first paste:

### Run #1

```
cd /opt/ycsb-0.10.0-SNAPSHOT
export workload=workloada
export workloadHost=52.41.74.211
export workloadThreads=35
export workloadThreadGroup=35
export runnumber=1
./bin/ycsb run couchbase2 -P workloads/${workload} -p couchbase.host=${workloadHost} -threads ${workloadThreads} -p couchbase.epoll=true -p couchbase.boost=16 -p maxexecutiontime=1200 -p operationcount=900000000 -jvm-args="-Dcom.couchbase.kvTimeout=50000" 2>&1 > ${workload}-${workloadThreadGroup}-4{runnumber}.log
```

Runs #2 and #3 - No need to repeat the cd or export command as they have been set in the environment.

Once the previous processing is complete you can perform another run from the same YCSB terminal window by pasting this command.

```
export runnumber=2
./bin/ycsb run couchbase2 -P workloads/${workload} -p couchbase.host=${workloadHost} -threads ${workloadThreads} -p couchbase.epoll=true -p couchbase.boost=16 -p maxexecutiontime=1200 -p operationcount=900000000 -jvm-args="-Dcom.couchbase.kvTimeout=50000" 2>&1 > ${workload}-${workloadThreadGroup}-${runnumber}.log
```

The process is actually the same when there is n number of nodes. You just have all the YCSB client terminal windows open and paste the exact command in all the required windows so that the commands are running at the same time across all the YCSB clients.  Or you can do this via a for loop with ssh:

```
for h in host1 host2 host3 … hostN; do
  export workload=workloada
  export workloadHost=52.41.74.211
  export workloadThreads=35
  export workloadThreadGroup=35
  export runnumber=1
  ssh $h "cd /opt/ycsb*; ./bin/ycsb run couchbase2 -P workloads/${workload} -p couchbase.host=${workloadHost} -threads ${workloadThreads} -p couchbase.epoll=true -p couchbase.boost=16 -p maxexecutiontime=1200 -p operationcount=900000000 -jvm-args='-Dcom.couchbase.kvTimeout=50000' > ${h}.out.runX 2>&1 &"
done
```
By varying the hosts in the for loop and iterating over N runs, you can collect the same workload A data in the benchmark.

At the end of all the runs you will have a number of .log files in the /opt/ycsb-0.10.0-SNAPSHOT directory that look like below. These files contain the output for the 3 runs.  They are named based on the total threads used for all clients running during this test and on which run number it was.  For example, workloade-63-3.log means this was for workloade Run 3 using 63 total threads (3 YCSB clients each with 21 threads). 21 x 3 = 63.

```
4 -rw-rw-r--   1 centos centos  1504 Jun 16 15:05 workloada-70-1.log
4 -rw-rw-r--   1 centos centos  1515 Jun 16 15:26 workloada-70-2.log
4 -rw-rw-r--   1 centos centos  1221 Jun 16 15:47 workloada-70-3.log
```

### Compress all the run log files on each YCSB server

Compress each YCSB server's output fles from the /opt/ycsb-0.10.0-SNAPSHOT directory:

```
for h in host1 host2 host3 … hostN; do
  ssh $h "cd /opt/ycsb*; zip ycsbNode1-workloada-Output.zip workloada*.log"
done
```

### Grab all the LOG files from each YCSB server

Download all of the compressed output files.


```
for h in host1 host2 host3 … hostN; do
  vagrant scp $h:/opt/ycsb-0.10.0-SNAPSHOT/ycsbNode1-workloada-Output.zip .
done
```




## Workload E

Note: replace 52.40.153.4 with the IP address of the first Couchbase server in all commands below.

### Create the Couchbase Index required for Workload E

Create Indexes when ready to perform workloade. This is not required for workload A. 

```
for h in 1 2 3 … hostN; do
  vagrant ssh host${h} -s "curl -v http://localhost:8093/query/service -d 'statement=CREATE PRIMARY INDEX `idx${h}` ON `default`'"
done
```


### Load Data for YCSB workloade test from YCSB Server 1

```
vagrant ssh ycsb1
cd /opt/ycsb-0.10.0-SNAPSHOT
export workload=workloade
export workloadHost=52.40.153.4
./bin/ycsb load couchbase2 -s -threads 35 -P workloads/workloade -p couchbase.host=${workloadHost}
```


### Running the YCSB workloade tests

For each group below after doing the search and replace mention above you paste the group of commands on each required YCSB server. 

```
for h in host1 host2 host3 … hostN; do
  export workload=workloade
  export workloadHost=52.40.153.4
  export workloadThreads=21
  export workloadThreadGroup=21
  export runnumber=1
  vagrant ssh $h -c "cd /opt/ycsb*; ./bin/ycsb run couchbase2 -P workloads/${workload} -p couchbase.host=${workloadHost} -threads ${workloadThreads} -p couchbase.epoll=true -p couchbase.boost=16 -p maxexecutiontime=1200 -p operationcount=900000000 -p couchbase.upsert=true 2>&1 > ${workload}-${workloadThreadGroup}-1.log &"
done
```

Increment runnumber for each iteration.  Update the hosts list to increase or decrease the number of client nodes.

At the end of all the runs you will have a number of .log files in the /opt/ycsb-0.10.0-SNAPSHOT directory that look like below. These files contains the output for of the 3 runs. 

They are named based on the total threads used for all clients running during this test and the run number. 

For example, workloade-63-3.log means this was for workloade Run 3 using 63 total threads (3 YCSB clients each with 21 threads). 21 x 3 = 63.

```
4 -rw-rw-r--   1 centos centos  1504 Jun 16 15:05 workloade-63-1.log
4 -rw-rw-r--   1 centos centos  1515 Jun 16 15:26 workloade-63-2.log
4 -rw-rw-r--   1 centos centos  1221 Jun 16 15:47 workloade-63-3.log
```

### Compress all the run log files on each YCSB server

Compress each YCSB server's output fles from the /opt/ycsb-0.10.0-SNAPSHOT directory:

```
for h in 1 2 3 … N; do
  vagrant ssh host${h} "cd /opt/ycsb*; zip ycsbNode${h}-workloade-Output.zip workloade*.log"
done
```

### Grab all the LOG files from each YCSB server

Download all of the compressed output files.


```
for h in 1 2 3 … N; do
  vagrant scp host${h}:/opt/ycsb-0.10.0-SNAPSHOT/ycsbNode${h}-workloade-Output.zip .
done
```
