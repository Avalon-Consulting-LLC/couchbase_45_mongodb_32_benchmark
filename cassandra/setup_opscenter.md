Enabling OpsCenter Monitoring
===

### Remote JMX

Enables remote JMX connections, which are useful for diagnostics, and necessary for OpsCenter.

Once enabled, `nodetool -u <username> -pw <password>` is required.

Steps:

- Run `enable_remote_jmx` given the service name and the file path of the `cassandra-env.sh` for that service.

username:passwd are set to cassandra:cassandra

```sh

enable_remote_jmx() {
  SERVICE=$1
  CONFIG=$2
  JMX_PASS_FILE=/etc/dse/cassandra/jmxremote.password
  JMX_ACCESS_FILE=/etc/dse/cassandra/jmxremote.access

  echo "cassandra cassandra" | sudo tee $JMX_PASS_FILE
  echo "controlRole jmxControl" | sudo tee -a $JMX_PASS_FILE

  sudo chown cassandra:cassandra $JMX_PASS_FILE
  sudo chmod 400 $JMX_PASS_FILE

  echo "cassandra readwrite" | sudo tee $JMX_ACCESS_FILE
  echo "controlRole readwrite \\" | sudo tee -a $JMX_ACCESS_FILE
  echo "          create javax.management.monitor.*,javax.management.timer.* \\" | sudo tee -a $JMX_ACCESS_FILE
  echo "          unregister" | sudo tee -a $JMX_ACCESS_FILE

  sudo chown cassandra:cassandra $JMX_ACCESS_FILE
  sudo chmod 400 $JMX_ACCESS_FILE

  TO_INSERT="  JVM_OPTS=\"\$JVM_OPTS -Dcom.sun.management.jmxremote.access.file=$JMX_ACCESS_FILE\""
  if ! sudo grep "$TO_INSERT" $CONFIG > /dev/null; then
      line=$(sudo cat $CONFIG | grep -n 'jmxremote.password.file' | grep -o '^[0-9]*')
      line=$((line + 1))
      sudo sed -i ${line}"i\\$TO_INSERT" $CONFIG
  fi
  sudo sed -i -r "s/(LOCAL_JMX)=.*/\1=no/" $CONFIG

  sudo service $SERVICE restart
}

disable_remote_jmx() {
  SERVICE=$1
  CONFIG=$2
  sudo sed -i -r "s/(LOCAL_JMX)=.*/\1=yes/" $CONFIG
  sudo service $SERVICE restart
}

enable_remote_jmx dse-node1 /etc/dse-node1/cassandra/cassandra-env.sh
enable_remote_jmx dse-node2 /etc/dse-node2/cassandra/cassandra-env.sh

```

### OpsCenter Agent

This requires Datastax account credentials. (free to sign-up)

See DataStax documentation about installing OpsCenter.

The following scripts are for setting up the agents on each of the server instances.

```sh

DATASTAX_AGENT_VER=6.0.5
# curl --user '<DSE_USERNAME>:<DSE_PASSWORD>' -L http://downloads.datastax.com/enterprise/datastax-agent-${DATASTAX_AGENT_VER}.tar.gz | sudo tar xz -C /opt
sudo mv /opt/datastax-agent-${DATASTAX_AGENT_VER} /opt/datastax-agent1
sudo cp -r /opt/datastax-agent1 /opt/datastax-agent2

setup_opsc() {
  agent_conf=$1
  stomp_iface=$2
  public_ip=$3
  jmx_port=$4

  echo "stomp_interface: $stomp_iface" | sudo tee $agent_conf
  echo "local_interface: $public_ip" | sudo tee -a $agent_conf
  echo "agent_rpc_interface: $public_ip" | sudo tee -a $agent_conf
  echo "agent_rpc_broadcast_address: $public_ip" | sudo tee -a $agent_conf
  echo "cassandra_rpc_interface: $public_ip" | sudo tee -a $agent_conf
  echo "jmx_port: $jmx_port" | sudo tee -a $agent_conf
  echo "jmx_user: cassandra" | sudo tee -a $agent_conf
  echo "jmx_pass: cassandra" | sudo tee -a $agent_conf
}

remote_ip='172.31.16.51' # stomp_interface, needs to point to OpsCenter
addr1='172.31.16.11'
addr2='172.31.16.12'

setup_opsc /opt/datastax-agent1/conf/address.yaml $remote_ip $addr1 7299
setup_opsc /opt/datastax-agent2/conf/address.yaml $remote_ip $addr2 7399

sudo /opt/datastax-agent1/bin/datastax-agent;

sudo /opt/datastax-agent2/bin/datastax-agent

```
