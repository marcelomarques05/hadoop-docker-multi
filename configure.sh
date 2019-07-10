#!/bin/bash

# Stop/Delete All
docker stop `docker ps | grep -v CONTAINER | awk '{print $1}'`

# Start Containers
docker run -d -it -h hadoop-master --name hadoop-master --rm -p 50070:50070 -p 8088:8088 -p 9864:9864 -p 9820:9820 ubuntu:bionic
docker run -d -it --link hadoop-master:hadoop-master -h hadoop-datanode01 --name hadoop-datanode01 --rm ubuntu:bionic
docker run -d -it --link hadoop-master:hadoop-master -h hadoop-datanode02 --name hadoop-datanode02 --rm ubuntu:bionic

# Install Packages
docker exec hadoop-master bash -c "apt-get update -y && apt-get install -y ssh rsync wget curl net-tools vim openjdk-8-jdk openjdk-8-jre inetutils-ping inetutils-telnet"
docker exec hadoop-datanode01 bash -c "apt-get update -y && apt-get install -y ssh rsync wget curl net-tools vim openjdk-8-jdk openjdk-8-jre inetutils-ping inetutils-telnet"
docker exec hadoop-datanode02 bash -c "apt-get update -y && apt-get install -y ssh rsync wget curl net-tools vim openjdk-8-jdk openjdk-8-jre inetutils-ping inetutils-telnet"

# SSH Conf
docker exec hadoop-master bash -c "/etc/init.d/ssh start"
docker exec hadoop-datanode01 bash -c "/etc/init.d/ssh start"
docker exec hadoop-datanode02 bash -c "/etc/init.d/ssh start"
docker exec hadoop-master bash -c "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys2"
docker exec hadoop-datanode01 bash -c "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys2"
docker exec hadoop-datanode02 bash -c "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys2"
docker cp hadoop-master:/root/.ssh/authorized_keys2 ./authorized_keys2_master
docker cp hadoop-datanode01:/root/.ssh/authorized_keys2 ./authorized_keys2_datanode01
docker cp hadoop-datanode02:/root/.ssh/authorized_keys2 ./authorized_keys2_datanode02
cat authorized_keys2_master authorized_keys2_datanode01 authorized_keys2_datanode02 > authorized_keys2
docker cp authorized_keys2 hadoop-master:/root/.ssh/authorized_keys2
docker cp authorized_keys2 hadoop-datanode01:/root/.ssh/authorized_keys2
docker cp authorized_keys2 hadoop-datanode02:/root/.ssh/authorized_keys2
docker exec hadoop-master bash -c "echo '$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hadoop-datanode01)' hadoop-datanode01 >> /etc/hosts"
docker exec hadoop-master bash -c "echo '$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hadoop-datanode02)' hadoop-datanode02 >> /etc/hosts"
docker exec hadoop-datanode01 bash -c "echo '$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hadoop-datanode02)' hadoop-datanode02 >> /etc/hosts"
docker exec hadoop-datanode02 bash -c "echo '$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hadoop-datanode01)' hadoop-datanode01 >> /etc/hosts"

# Hadoop Configuration
# hadoop-master
docker exec hadoop-master bash -c "mkdir -p /opt/hadoop/logs && mkdir -p /opt/hdfs/datanode && mkdir -p /opt/hdfs/namenode && mkdir -p /opt/yarn/logs"
docker exec hadoop-master bash -c "wget http://ftp.unicamp.br/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz -P /opt/"
docker exec hadoop-master bash -c "tar -xzvf /opt/hadoop-3.1.2.tar.gz --exclude=hadoop-3.1.2/share/doc --directory=/opt/hadoop --strip 1"
docker exec hadoop-master bash -c "echo 'export HADOOP_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_NAMENODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_DATANODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_SECONDARYNAMENODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HADOOP_MAPRED_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HADOOP_COMMON_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HADOOP_HDFS_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export YARN_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HADOOP_HOME=/opt/hadoop' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HADOOP_LOG_DIR=/opt/hadoop/logs' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HDFS_NAMENODE_USER="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HDFS_NAMENODE_GROUP="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HDFS_DATANODE_USER="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export HDFS_SECONDARYNAMENODE_USER="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export YARN_NODEMANAGER_USER="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-master bash -c "echo 'export YARN_RESOURCEMANAGER_USER="root"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker cp conf/. hadoop-master:/opt/hadoop/etc/hadoop/
docker exec hadoop-master bash -c "hdfs namenode -format"

#hadoop-datanode01
docker exec hadoop-datanode01 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /root/.bashrc"
docker exec hadoop-datanode01 bash -c "mkdir -p /opt/hadoop/logs && mkdir -p /opt/hdfs/datanode && mkdir -p /opt/hdfs/namenode && mkdir -p /opt/yarn/logs"
docker exec hadoop-datanode01 bash -c "wget http://ftp.unicamp.br/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz -P /opt/"
docker exec hadoop-datanode01 bash -c "tar -xzvf /opt/hadoop-3.1.2.tar.gz --exclude=hadoop-3.1.2/share/doc --directory=/opt/hadoop --strip 1"
docker cp conf/. hadoop-datanode01:/opt/hadoop/etc/hadoop/

#hadoop-datanode02
docker exec hadoop-datanode02 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /root/.bashrc"
docker exec hadoop-datanode02 bash -c "mkdir -p /opt/hadoop/logs && mkdir -p /opt/hdfs/datanode && mkdir -p /opt/hdfs/namenode && mkdir -p /opt/yarn/logs"
docker exec hadoop-datanode02 bash -c "wget http://ftp.unicamp.br/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz -P /opt/"
docker exec hadoop-datanode02 bash -c "tar -xzvf /opt/hadoop-3.1.2.tar.gz --exclude=hadoop-3.1.2/share/doc --directory=/opt/hadoop --strip 1"
docker cp conf/. hadoop-datanode02:/opt/hadoop/etc/hadoop/

# Start Hadoop
docker exec hadoop-master bash -c "/opt/hadoop/sbin/start-dfs.sh"