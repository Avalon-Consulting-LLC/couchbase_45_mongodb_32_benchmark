# AWS Multi instance Datastax Enterprise
===

### Multiple IP addresses

**First** Go to EC2 console, and add secondary private IP address

```sh
# Change to the IP set in AWS console
second_addr='172.31.16.28'

# More permanent solution
sudo cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0:0
sudo sed -i -r "s/^DEVICE=(eth0)$/DEVICE=\1:0/" /etc/sysconfig/network-scripts/ifcfg-eth0:0

echo "IPADDR=${second_addr}" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth0:0
echo "NETMASK=255.255.240.0" | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth0:0

sudo service network restart; ip addr li

# Does not persist reboot
sudo ip addr add "${second_addr}/24" dev eth0
```

### Setup

```sh
configure_instance() {
  node_id=$1
  cassandra_dir=$2
  host_addr=$3

  snitch_type=Ec2Snitch

  ## Ensure JMX is open
  sudo sed -i -r "s/^# (.*java\.rmi\.server\.hostname)([^\"]+)/\1=$host_addr/" ${cassandra_dir}/cassandra-env.sh
  ## Set recommended num_tokens
  sudo sed -i -r "s/^# (num_tokens): .*$/\1: 256/" ${cassandra_dir}/cassandra.yaml
  ## Using EC2
  sudo sed -i -r "s/^(endpoint_snitch): .*$/\1: $snitch_type/" ${cassandra_dir}/cassandra.yaml
  ## Allowing more threads
  sudo sed -i -r "s/^# (native_transport_max_threads): .*$/\1: 500/" ${cassandra_dir}/cassandra.yaml

  ## Toggle commit log settings - defaults are batch
  # sudo sed -i -r "s/^# (commitlog_sync: periodic)$/\1/" /etc/dse-node1/cassandra/cassandra.yaml
  # sudo sed -i -r "s/^# (commitlog_sync_period_in_ms: 10000)$/\1/" /etc/dse-node1/cassandra/cassandra.yaml
  #
  # sudo sed -i -r "s/^(commitlog_sync: batch)/# \1/" /etc/dse-node1/cassandra/cassandra.yaml
  # sudo sed -i -r "s/^(commitlog_sync_batch_window_in_ms: 2)/# \1/" /etc/dse-node1/cassandra/cassandra.yaml

  cpu_cores=$( getconf _NPROCESSORS_ONLN )
  disks=3
  sudo sed -i -r "s/^(concurrent_writes): .*$/\1: $(( 8 * $cpu_cores ))/" ${cassandra_dir}/cassandra.yaml
  sudo sed -i -r "s/^(concurrent_counter_writes): .*$/\1: $(( 16 * $disks ))/" ${cassandra_dir}/cassandra.yaml

  sudo sed -i -r "s/^#(memtable_flush_writers): .*$/\1: $cpu_cores/" ${cassandra_dir}/cassandra.yaml

  ## Compaction settings
  sudo sed -i -r "s/^#(concurrent_compactors): .*$/\1: $cpu_cores/" ${cassandra_dir}/cassandra.yaml
  sudo sed -i -r "s/^(compaction_throughput_mb_per_sec): .*$/\1: 128/" ${cassandra_dir}/cassandra.yaml

  sudo chkconfig dse-$node_id --add
  sudo chkconfig dse-$node_id on
}

# Switching single instance service for multi instance services
sudo chkconfig dse off

## Make sure this does not contain a current IP(s) unless setting up first node
seeds='172.31.16.11,172.31.16.15'
## Try to use odd-numbered IPs (the evens are the secondary private IPs, not sure if will work)

## Set all IP addresses of current node
addr1='172.31.16.27'
addr2='172.31.16.28'

## Add Node 1
# node_id=node1
# jmx1_port=7299
sudo dse add-node --node-id node1 --cluster Cassandra \
  --listen-address $addr1 --rpc-address $addr1 --seeds $seeds --jmxport 7299 \
  --data-directory /cassandra1

configure_instance node1 /etc/dse-node1/cassandra $addr1

## Start the service
sudo service dse-node1 start;
sleep 10; # File won't be available immediately
sudo tail -f /var/log/dse-node1/system.log

## ... wait for "DSE startup complete" (hopefully)

## Add node 2
# node_id=node2
# jmx2_port=7399
sudo dse add-node --node-id node2 --cluster Cassandra \
  --listen-address $addr2 --rpc-address $addr2 --seeds $seeds --jmxport 7399 \
  --data-directory /cassandra2

configure_instance node2 /etc/dse-node2/cassandra $addr2

## Start the service
sudo service dse-node2 start;
sleep 10; # File won't be available immediately
sudo tail -f /var/log/dse-node2/system.log

## ... wait for "DSE startup complete" (hopefully)

```

### Settings verification

Good idea to run these before the services are started, or if having diagnostic troubles.

```sh
# Check JMX Addresses set correctly
sudo cat /etc/dse-node1/cassandra/cassandra-env.sh | grep "java.rmi.server.hostname"
sudo cat /etc/dse-node2/cassandra/cassandra-env.sh | grep "java.rmi.server.hostname"

# Check the seeds for the nodes
sudo cat /etc/dse-node1/cassandra/cassandra.yaml | grep "seeds:"
sudo cat /etc/dse-node2/cassandra/cassandra.yaml | grep "seeds:"
```

### Check multi-node status

```sh
# Documented way
sudo dse node1 dsetool ring
# OR
nodetool -p 7299 status
# OR
nodetool -p 7299 ring
```

*`nodetool -p <port> -h <host_ip> status` times out because JMX only listens on localhost, by default*  
*See Remote JMX section of OpsCenter setup for details*

### Cleanup

*TODO: If node has joined, or attempted to join, cluster, you should probably remove the node. See Datastax `nodetool remove` docs*

```sh
clean_node() {
  nodeid=$1
  data_dir=$2

  sudo service "dse-${nodeid}" stop; sleep 10
  sudo dse remove-node ${nodeid} --yes
  sudo rm -rf "/var/lib/dse-${nodeid}/"
  sudo rm -rf "/var/log/dse-${nodeid}/"

  sudo rm -rf ${data_dir}/*
}

clean_node node1 /cassandra1
clean_node node2 /cassandra2

# service stop doesn't work reliably...
# Check if processes still running
sudo netstat -antlp | grep 7299 # node1
sudo netstat -antlp | grep 7399 # node2

sudo kill -9 <process_num> # if needed
```

See Check status to see if node still in ring.


### Stress Load without YCSB

You can use `cassandra-stress` to get a feel for performance.

This example was modified from the documentation and ran after a `write n=1000000` operation.  

```sh
export node=172.31.16.11
cassandra-stress mixed ratio\(write=1,read=1\) n=1000000 cl=QUORUM -pop dist=UNIFORM\(1..1000000\) -mode native cql3 -rate threads\>=21 threads\<=600 -node $node -port jmx=7299 -log file=~/mixed_autorate_50r50w_1M.log
```

---

### Random notes

These lines could be important to modify

*`/etc/dse/dse-nodeId/dse.yaml`* - line 496, 583, 889

---

### References

[DSE 5.0 Multi-Instance Demo](https://github.com/simonambridge/DataStax-5.0-Multi-Instance-Demo)  
[Create multiple IP addresses for one interface](http://www.tecmint.com/create-multiple-ip-addresses-to-one-single-network-interface/)  
[Add multiple private IP addresses to one EC2 instance](http://flummox-engineering.blogspot.com/2014/01/add-multiple-private-ip-addresses-to.html)  
