#!/bin/bash
# brew-hadoop-setup.sh, version 2.0
# 
# Run the script as root.
# 
# Info: Quickly setup dev hadoop environment using brew on mac. Contains basic 
#       configuration for cluster mode deployment on a single node.
# 
# -- Robin (d.robin@gmail.com) -- 2016-09 --


# 1. Directory for HDFS
sudo mkdir -p /opt/hadoop
sudo chown -R $USER /opt/hadoop

# 2. Setup core-site.xml
corepath=$(find /usr/local/Cellar/hadoop -name core-site.xml | \grep 'etc/hadoop')
cp $corepath $(dirname $corepath)/core-site.xml.bak_`date +%Y-%m-%d--%H-%M-%S`

echo '<configuration>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/hadoop/tmp/hadoop-${user.name}</value>
        <description>A base for other temporary directories.</description>
    </property>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>' > $corepath


# 3. Setup hdfs-site.xml
hdfssite=$(find /usr/local/Cellar/hadoop -name hdfs-site.xml | \grep 'etc/hadoop')
cp $hdfssite $(dirname $hdfssite)/hdfs-site.xml.bak_`date +%Y-%m-%d--%H-%M-%S`

echo '<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/hadoop/data/dfs.namenode.name.dir</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data/dfs.datanode.data.dir</value>
    </property>
</configuration>' > $hdfssite


# 4. Setup yarn-site.xml
yarnsite=$(find /usr/local/Cellar/hadoop -name yarn-site.xml | \grep 'etc/hadoop')
cp $yarnsite $(dirname $yarnsite)/yarn-site.xml.bak_`date +%Y-%m-%d--%H-%M-%S`

echo '<configuration>

<!-- Site specific YARN configuration properties -->
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>' > $yarnsite


# 5. Setup mapred-site.xml
# Do not run the following commands if you are not using Apache Tez
mapredsite=$(find /usr/local/Cellar/hadoop -name mapred-site.xml | \grep 'etc/hadoop')
if [ -n "$mapredsite" ]; then
    cp $mapredsite $(dirname $mapredsite)/mapred-site.xml.bak_`date +%Y-%m-%d--%H-%M-%S`
    #mapredsite=$(dirname $hdfssite)
else
    mapredsite=$(dirname $hdfssite)/mapred-site.xml
fi

echo '<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn-tez</value>
    </property>
</configuration>' > $mapredsite

# End Tez configuration

# 6. enable start-dfs.sh & start.yarn.sh
echo '

Configuration files are setup. Hadoop data directory points to location /opt/hadoop/data

Add following export to .bash_profile to use commands start-dfs.sh & start-yarn.sh,
export PATH="/usr/local/sbin:$PATH"

Hadoop first time usage, commands.
1. $ hdfs namenode -format
2. $ start-dfs.sh && start-yarn.sh

'
