FROM ubuntu:bionic

EXPOSE 50070 50075 50030 51111 8088 9864

RUN apt-get update -y && apt-get install -y ssh rsync wget curl net-tools vim openjdk-8-jdk openjdk-8-jre inetutils-ping inetutils-telnet && mkdir /opt/hadoop
ADD http://ftp.unicamp.br/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz /opt/
RUN tar -xzvf /opt/hadoop-3.1.2.tar.gz --exclude=hadoop-3.1.2/share/doc --directory=/opt/hadoop --strip 1 && rm -f /opt/hadoop-3.1.2.tar.gz
COPY conf/ /opt/hadoop/etc/hadoop/