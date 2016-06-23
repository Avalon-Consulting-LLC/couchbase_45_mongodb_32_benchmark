# The following configuration changes were made for MongoDB

Set wired tiger available memory:

  * `storage.wiredTiger.engineConfig.cacheSizeGB`

To set readPreference to nearest on mongodb ycsb call:

  * `?readPreference=nearest`

Example YCSB Execution Command (Workload A)

* ```./bin/ycsb load mongodb -s -threads 45 -P workloads/workloada -p mongodb.url="mongodb://host:port/usertable?readPreference=nearest"```

# Example private_settings.yml

```
aws:
  access_key_id: key
  secret_access_key: secret

benchmark:
  keypairname: "keypair"
  secgroups: ["securitygroup"]
  db_ami: "db ami"
  db_size: "db instance type"
  client_ami: "client ami"
  client_size: "client instance type"
  ycsb_ami: "ycsb ami"
  ycsb_instance_type: "ycsb instance type"
  subnet_id: "subnet id"
ssh:
  username: centos
  private_key_path: /path/to/pem/key.pem
```
  
# Steps for standing up MongoDB Environment

1. To stand up the MongoDB environment

  * Verify/update any necessary settings in private_settings.yml
  * Run the following command: ```vagrant up --provider=aws``` 
  * Verify that mongodb is running and set up correctly by accessing mongos

1. Enable enhanced networking in AWS

  *  For documentation relating to AWS and Enhanced Networking go to: [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html]()

1. Restart EC2 instances and mongodb servers

1. Verify network speeds

  * Run IPERF to verify network speeds
  * AMI already included iperf
  * Just need to run
      * `iperf3 —server` on the db vm
      *  and the `iperf3 —client <<IP_OF_SERVER>>` on the YCSB client

    