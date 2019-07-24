FROM ubuntu:bionic
LABEL description="This is a custom Hadoop Server for Docker - Just for Fun..."
LABEL maintainer="Marcelo Marques <marcelo@smarques.com>"

EXPOSE 50070 50075 50030 51111 8088 9864
# OS Packages Download - Default
RUN apt-get update -y && apt-get install -y ssh rsync wget curl net-tools vim inetutils-ping inetutils-telnet
# Hadoop Packages
ADD http://ftp.unicamp.br/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz /opt/
RUN mkdir /opt/hadoop && tar -xzvf /opt/hadoop-3.1.2.tar.gz --exclude=hadoop-3.1.2/share/doc --directory=/opt/hadoop --strip 1 && rm -f /opt/hadoop-3.1.2.tar.gz
COPY hadoop-conf/ /opt/hadoop/etc/hadoop/
# OS Packages - Download - Extras
RUN apt-get install -y openjdk-8-jdk openjdk-8-jre
# OS Files - Default
COPY conf/profile /root/.profile