Load YCSB
===

## Init table

```sh
export CQLSH_HOST=172.31.16.11 # SSH to this host
cqlsh -f /vagrant/ycsb_data/db_init/cassandra.cql
```

## Load

```sh
export workload=workloade
export workloadPath=/vagrant/ycsb_data/workloads/benchmark-${workload}
export workloadHost=172.31.16.11,172.31.16.12,172.31.16.13,172.31.16.14,172.31.16.15,172.31.16.17,172.31.16.18,172.31.16.19,172.31.16.20,172.31.16.21,172.31.16.22,172.31.16.23,172.31.16.24,172.31.16.25,172.31.16.26,172.31.16.27,172.31.16.28
export workloadThreads=35

export YCSB_CMD="bin/ycsb load cassandra-cql -s -threads ${workloadThreads} -P ${workloadPath} -p maxexecutiontime=36000 -p hosts=${workloadHost} -p cassandra.connecttimeoutmillis=50000 -p cassandra.writeconsistencylevel=ANY"

export YCSB_NODES=4 # ensure vagrant knows about these

export recordcount=$(( 150000000 / $YCSB_NODES ))
for i in $(seq 0 $(($YCSB_NODES - 1)))
do
  # echo "$(printf '%02d' $i)"
  host="ycsb$(printf '%02d' $((i + 1)))"
  # vagrant ssh $host -c "nohup (/opt/ycsb/$YCSB_CMD -p insertstart=$(($recordcount * $i)) -p insertcount=$recordcount) &"
  vagrant ssh $host -c "nohup /opt/ycsb/$YCSB_CMD -p insertstart=$(($recordcount * $i)) -p insertcount=$recordcount >  /home/centos/load-$workload.log 2> /home/centos/load-$workload.err < /dev/null & sleep 1"
done
```
