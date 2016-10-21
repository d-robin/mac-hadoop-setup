#!/bin/bash
# brew-tez-setup.sh, version 2.0
# 
# Info: Setup tez on mac/brew environment
# 
# Prerequisite: 
# 1. maven & protobuf, install using brew 
#   $ brew install maven
#   $ brew install protobuf250
# 2. hadoop must be running for hdfs commands
#   $ start-dfs.sh
#   $ start-yarn.sh
# 
# -- Robin (d.robin@gmail.com) -- 2016-09 --


# **IMPORTANT**
# Comment/Skip step 1 & 2 if tez is already compiled.
# Run the script from the right directory

#Step 0

# Step 1: Download and extract
wget http://apache.spinellicreations.com/tez/0.8.4/apache-tez-0.8.4-src.tar.gz
tar xvzf apache-tez-0.8.4-src.tar.gz

# Step 2: Fix configuration & Build
sed -i '.backup' "s/<hadoop.version>.*/<hadoop.version>`basename $(ls /usr/local/Cellar/hadoop/)`<\/hadoop.version>/" apache-tez-0.8.4-src/pom.xml
sed -i '.backup1' "s/<protobuf.version>.*/<protobuf.version>2.5.0<\/protobuf.version>/" apache-tez-0.8.4-src/pom.xml
mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true -f apache-tez-0.8.4-src/pom.xml

# Step 3: Setup environment
sudo mkdir -p /opt/tez/jars /opt/tez/conf
sudo chown -R $USER /opt/tez
TEZ_JARS=/opt/tez/jars
cp apache-tez-0.8.4-src/tez-dist/target/tez-0.8.4-minimal.tar.gz apache-tez-0.8.4-src/tez-dist/target/tez-0.8.4.tar.gz /opt/tez
tar xvzf /opt/tez/tez-0.8.4-minimal.tar.gz -C $TEZ_JARS

echo '<configuration>
	<property>
		<name>tez.lib.uris</name>
		<value>${fs.defaultFS}/tez/tez-0.8.4.tar.gz</value>
	</property>
</configuration>' > /opt/tez/conf/tez-site.xml

hdfs dfs -mkdir /tez
hdfs dfs -put /opt/tez/tez-0.8.4.tar.gz /tez

# Step 4: Additional config (Important)
echo 'Add following exports in .bash_profile ,

export TEZ_CONF_DIR=/opt/tez/conf
export TEZ_JARS=/opt/tez/jars
export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*:${HADOOP_CLASSPATH}


Later stop hadoop services, open a new terminal and start hadoop services again.

To test tez, you could use the following commands,

hdfs dfs -rm -r -f /input
hdfs dfs -mkdir /input
echo "Please note that the tarball version should match the version of the client jars used when submitting Tez jobs to the cluster. Please refer to the Version Compatibility Guide for more details on version compatibility and detecting mismatches." > /tmp/input.txt
hdfs dfs -put /tmp/input.txt /input
hadoop jar /opt/tez/jars/tez-examples-0.8.4.jar orderedwordcount /input /output
hdfs dfs -rm -r -f /input
hdfs dfs -rm -r -f /output
rm /tmp/input.txt
'
