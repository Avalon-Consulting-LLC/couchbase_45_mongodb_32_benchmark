#!/bin/bash

export serverUserName=centos

# Install java first
jversion=`java -version 2>&1 | awk -F '"' '/version/ {print $2}'`
echo $jversion

if [[ "$jversion" < "1.8" ]]; then
   wget --quiet --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.rpm"
   yum -y localinstall jdk-8u77-linux-x64.rpm
   alternatives --set java /usr/java/jdk1.8.0_77/jre/bin/java
   java -version
fi

if grep -q "JAVA_HOME" .bashrc
then
   echo "JAVA_HOME already set in .bashrc"
else
   echo "Setting JAVA_HOME in .bashrc"
   echo "export JAVA_HOME=/usr/java/jdk1.8.0_77" >> ~/.bashrc
fi

if grep -q "M2_HOME" .bashrc
then
   echo "M2_HOME already set in .bashrc"
else
   echo "Setting Maven M2_HOME in .bashrc and updating the system PATH"
   wget --quiet http://www.motorlogy.com/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
   tar -xzpf apache-maven-3.3.9-bin.tar.gz
   echo "export M2_HOME=/home/${serverUserName}/apache-maven-3.3.9" >> .bash_profile
   echo "export PATH=/home/${serverUserName}/apache-maven-3.3.9/bin:${PATH}" >> .bash_profile
   source .bash_profile
fi

yum -y install git

if [ ! -d couchbase-jvm-core ]; then
   git clone https://github.com/couchbase/couchbase-jvm-core.git
fi

echo "Building couchbase-jvm-core"
cd couchbase-jvm-core
mvn -quiet clean install -Dmaven.test.skip=true
cd ..

if [ ! -d YCSB ]; then
   git clone https://github.com/ingenthr/YCSB.git
fi

echo "Building YCSB"
cd YCSB
git checkout n1ql-raw
mvn --quiet clean package -DskipTests
cd ..

echo "Copying the YCSB workload configuration files"
cd /opt
tar xfz /home/${serverUserName}/YCSB/distribution/target/ycsb-0.10.0-SNAPSHOT.tar.gz
cp /vagrant/workloads/awbenchmark-workloada /opt/ycsb-0.10.0-SNAPSHOT/workloads/workloada
cp /vagrant/workloads/awbenchmark-workloade /opt/ycsb-0.10.0-SNAPSHOT/workloads/workloade

echo "Updating directory permissions"
chown -R ${serverUserName}:${serverUserName} /home/${serverUserName}
chown -R ${serverUserName}:${serverUserName} /opt/ycsb-0.10.0-SNAPSHOT
cd /opt/ycsb-0.10.0-SNAPSHOT

echo "Testing YCSB"
./bin/ycsb load basic -s -P workloads/workloada -p recordcount=5

