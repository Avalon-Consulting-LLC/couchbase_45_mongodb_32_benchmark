# Couchbase 4.5 - MongoDB 3.2 Benchmark
This repository contains the scripts necessary to conduct the Couchbase/MongoDB benchmarks conducted by Avalon Consulting, LLC. in June 2016.  See the README.md files in each directory for additional details.  Care has been taken to accurately reproduce the steps in a manner that will be straightforward to execute.  In case this proves incorrect, please submit an issue on this repository.

## Prerequisites

The following tools are required to configure and run the benchmark:

* Vagrant with the AWS plugin
* Ansible
* the aws command line (CLI) utility

You will also need the following:

* An AWS account with access and secret keys
* Defined security group in AWS
* A defined VPC and subnet in AWS


## Overview

The high-level flow is:

1. Clone this repository
1. Setup AWS network (vpc, subnet, keys, etc.).  This is a manual step.
1. Edit private\_settings.yml to include your AWS keys, subnets, vpc, etc.  Use private\_settings\_example.yml as a starting point.
1. Provision Couchbase virtual machines using Vagrant and Ansible - see couchbase directory
1. Provision MongoDB virtual machines using Vagrant and Ansible - see mongodb directory
1. Provision YCSB client virtual machines using Vagrant and Ansible - see ycsb\_client directory
    1. Load Couchbase dataset using YCSB
    1. Run Couchbase benchmark using YCSB
    1. Load MongoDB dataset using YCSB
    1. Run MongoDB benchmark using YCSB
