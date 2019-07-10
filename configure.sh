#!/bin/bash

JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Build hadoop-image
docker build . -t hadoop-image:1

# Stop/Delete All
if [ `docker ps | grep -v CONTAINER | wc -l` != 0 ]; then
    docker stop `docker ps | grep -v CONTAINER | awk '{print $1}'`
    sleep 5
fi

# Start Containers
docker run -d -it -h hadoop-master --name hadoop-master --rm -p 8030:8030 -p 8032:8032 -p 8033:8033 -p 8088:8088 -p 9870:9870 -p 9871:9871 hadoop-image:1
docker run -d -it --link hadoop-master:hadoop-master -h hadoop-datanode01 --name hadoop-datanode01 --rm -p 9864:9864 hadoop-image:1
docker run -d -it --link hadoop-master:hadoop-master -h hadoop-datanode02 --name hadoop-datanode02 --rm -p 9865:9864 hadoop-image:1

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
docker exec hadoop-master bash -c "echo 'export HADOOP_HOME=/opt/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_NAMENODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_DATANODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export HDFS_SECONDARYNAMENODE_USER=root' >> /root/.bashrc"
docker exec hadoop-master bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /root/.bashrc"
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

#hadoop-datanode01
docker exec hadoop-datanode01 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /root/.bashrc"
docker exec hadoop-datanode01 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-datanode01 bash -c "mkdir -p /opt/hadoop/logs && mkdir -p /opt/hdfs/datanode && mkdir -p /opt/hdfs/namenode && mkdir -p /opt/yarn/logs"

#hadoop-datanode02
docker exec hadoop-datanode02 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /root/.bashrc"
docker exec hadoop-datanode02 bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /opt/hadoop/etc/hadoop/hadoop-env.sh"
docker exec hadoop-datanode02 bash -c "mkdir -p /opt/hadoop/logs && mkdir -p /opt/hdfs/datanode && mkdir -p /opt/hdfs/namenode && mkdir -p /opt/yarn/logs"

# Start Hadoop
docker exec hadoop-master bash -c "/opt/hadoop/bin/hdfs namenode -format"
docker exec hadoop-master bash -c "/opt/hadoop/sbin/start-all.sh"