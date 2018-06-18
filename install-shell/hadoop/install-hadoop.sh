#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

open_port () {
    pdsh -w ^hadoop_cluster sudo systemctl stop firewalld.service
    pdsh -w ^hadoop_cluster sudo systemctl enable firewalld.service
    pdsh -w ^hadoop_cluster sudo systemctl disable firewalld.service

    pdsh -w ^hadoop_cluster sudo firewall-cmd --zone=public --add-port=8485/tcp --permanent
    pdsh -w ^hadoop_cluster sudo firewall-cmd --zone=public --add-port=8480/tcp --permanent
    pdsh -w ^hadoop_cluster sudo firewall-cmd --reload
}

install() {
    APP_HOME=$1
    HADOOP_FILE=$2
    HADOOP_VERSION=$3
    USER_HOME=/home/"$4"/
    
    HADOOP_HOME="${APP_HOME}"/hadoop

	echo "Copying Hadoop $HADOOP_VERSION to all hosts..."
	pdcp -w ^hadoop_hosts "${HADOOP_FILE}" "${APP_HOME}/"
	pdsh -w ^hadoop_hosts tar -zxf "${APP_HOME}/${HADOOP_FILE}" -C "${APP_HOME}/"
	pdsh -w ^hadoop_hosts rm -rf "${HADOOP_HOME}"
	pdsh -w ^hadoop_hosts ln -s "${APP_HOME}/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}"
	
	echo "Set HADOOP_HOME env to all hosts..."
	pdsh -w ^hadoop_hosts echo "export HADOOP_HOME=${HADOOP_HOME}" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hadoop_hosts echo "PATH='\$PATH':${HADOOP_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hadoop_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"
	
	echo "Copying Hadoop config file to all hosts..."
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/core-site.xml" "${HADOOP_HOME}/etc/hadoop/"
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/hadoop-env.sh" "${HADOOP_HOME}/etc/hadoop/"
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/hdfs-site.xml" "${HADOOP_HOME}/etc/hadoop/"
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/mapred-site.xml" "${HADOOP_HOME}/etc/hadoop/"
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/yarn-site.xml" "${HADOOP_HOME}/etc/hadoop/"
	pdcp -w ^hadoop_hosts "${INSTALL_HOME}/conf/slaves" "${HADOOP_HOME}/etc/hadoop/"
	
	echo "Installing Hadoop to all hosts success ..."
}

initial() {
    NameNode=$1
    SecondaryNameNode=$2
    ResourceManager=$3
    
    echo "Initial NameNode: ${NameMode} SecondaryNameNode: ${SecondaryNameNode} ResourceManager:${ResourceManager} ..."
    echo "Start journalnode ................."
    pdsh -w ^hadoop_cluster "${HADOOP_HOME}"/sbin/hadoop-daemon.sh start journalnode
    echo "NameNode: ${NameNode} format ................."
    pdsh -w "${NameNode}" "${HADOOP_HOME}"/bin/hdfs namenode -format
    echo "NameNode: ${NameNode} start ................."
    pdsh -w "${NameNode}" "${HADOOP_HOME}"/sbin/hadoop-daemon.sh start namenode
    echo "NameNode: ${SecondaryNameNode} bootstrapStandby ................."
    pdsh -w "${SecondaryNameNode}" "${HADOOP_HOME}"/bin/hdfs namenode -bootstrapStandby
    echo "Stop all ................."
    pdsh -w ^hadoop_cluster "${HADOOP_HOME}"/sbin/stop-all.sh
    echo "NameNode: ${NameNode} zkfc -formatZK ................."
    pdsh -w "${NameNode}" "${HADOOP_HOME}"/bin/hdfs zkfc -formatZK
    
    echo "Initial NameNode: ${NameMode} SecondaryNameNode: ${SecondaryNameNode} ResourceManager:${ResourceManager} success ..."
    
    echo "Start Hadoop on ResourceManager:${ResourceManager} ..."
    pdsh -w "${ResourceManager}" "${HADOOP_HOME}"/sbin/start-all.sh
    
    echo "Start Hadoop success ..."
}

PARAMS=$#
if [ $PARAMS != 4 ] && [ $PARAMS != 5 ]; then
    echo "Usage:install-hadoop [install|initial] [APP_HOME|NameNode] [HADOOP_FILE|SecondaryNameNode] [HADOOP_VERSION|ResourceManager] [USER]"
    exit
fi

if [ $PARAMS == 5 ] && [ $1 == "install" ] ; then
    echo "install hadoop $2 $3 $4 $5 ........."
    install $2 $3 $4 $5
    exit
fi

if [ $PARAMS == 4 ] && [ $1 == "initial" ] ; then
    echo "initial hadoop NameNode:$2 SecondaryNameNode:$3 ResourceManager:$4 ........."

    initial $2 $3 $4

    exit
fi

echo "Usage:install-hadoop [install|initial] [APP_HOME|NameNode] [HADOOP_VERSION|SecondaryNameNode] [USER|ResourceManager]"