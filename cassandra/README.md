Cassandra Benchmark
===

Getting started:

  * Sign up for Datastax Enterprise
    * Credentials go in datastax_credentials.yml (Rename the example file)
  * The following files can go into `vagrant/deps`, but will be downloaded if non-existing
    * Oracle JDK (recommended) RPM
    * Miniconda Python installer
    * YCSB release tarball

Variable Ansible provisioner settings include the following.

  * Java OpenJDK / Oracle JDK
  * DataStax Community / Enterprise
  * Miniconda Python version
  * YCSB release version

See roles folders for variable specifics.  

Credentials are not necessary for DataStax Community.

Vagrantfile defaults to 1 database node and 1 YCSB client. Can be modified with environment variables `CASSANDRA_NODES` and `YCSB_NODES`.

For example, `CASSANDRA_NODES=2 YCSB_NODES=1 vagrant <command>` for 2 Cassandra instances and 1 YCSB instance.

Nodes are labeled `cassandra01..NN`, i.e. with two-digit padding.

`vagrant up` defaults to Virtualbox, add `--provider=aws` for AWS. A `private_settings.yml` file (see example) is needed, but only is read for the AWS provider.

All available machines (limited by other variables) will be provisioned by default. To specify certain nodes to be provisioned, set `ANSIBLE_LIMIT` to an [Ansible pattern][ansible-pattern]. E.g. `ANSIBLE_LIMIT="cassandra[6:]" vagrant provision` will provision all nodes in the `cassandra` Ansible group starting with the sixth and going until the end of the group.

### Using `ycsb-driver`

`ycsb-driver.sh` is a wrapper script that can be used to simplify the benchmarking process.

In order to use it, the `driver` and `host` variables within the file must be set.

The default load operation will load 150 million records.

Here are it's options.

```
YCSB Benchmark Wrapper script
Usage: ./ycsb_driver.sh [-t|--threads <arg>] [-c|--clients <arg>] [-r|--run <arg>] [-h|--help] <workload> [<op>]
	<workload>: YCSB workload name
	<op>: Operation (run|load|read) (default: 'run')
	-t,--threads: Number of threads (default: 35)
	-c,--clients: Number or clients (default: 1)
	-r,--run: Run number (default: 1)
	-h,--help: Prints help
```

### YCSB Vagrant Setup (deprecated)

 There is a separate Vagrantfile. This can be ran with `VAGRANT_VAGRANTFILE=Vagrantfile.ycsb vagrant up`, for example. Again, this uses the `private_settings.yml` for AWS settings.

### Notes

Was unable to get [Vagrant AWS box][vagrant-aws] added. Ran `VAGRANT_LOG=debug vagrant status` to see an error about vagrant embedded curl was outdated. [Deleting that curl binary][curl-error] allowed continuation.

[YCSB Cassandra binding][ycsb-cassandra]

  [vagrant-aws]: https://github.com/mitchellh/vagrant-aws#quick-start
  [curl-error]: http://stackoverflow.com/questions/40477731/mac-osx-sierra-cant-add-vagrant-box-laravel-homestead-due-to-needing-curl-v-9
  [ansible-pattern]: http://docs.ansible.com/ansible/intro_patterns.html
  [ycsb-cassandra]: https://github.com/brianfrankcooper/YCSB/tree/0.11.0/cassandra
