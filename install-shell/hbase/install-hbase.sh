#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

install() {
   APP_HOME=$1
   HBASE_FILE=$2
   HBASE_VERSION=$3
   HADOOP_HOME=$4
   USER_HOME=/home/"$5"/
   
   HBASE_HOME="${APP_HOME}"/hbase

	echo "Copying HBase $HBASE_VERSION to all hosts..."
	pdcp -w ^hbase_hosts "${HBASE_FILE}" "${APP_HOME}/"
	pdsh -w ^hbase_hosts tar -zxf "${APP_HOME}/${HBASE_FILE}" -C "${APP_HOME}/"
	pdsh -w ^hbase_hosts rm -rf "${HBASE_HOME}"
	pdsh -w ^hbase_hosts ln -s "${APP_HOME}/hbase-${HBASE_VERSION}" "${HBASE_HOME}"
	
	echo "Set HBASE_HOME env to all hosts..."
	pdsh -w ^hbase_hosts echo "export HBASE_HOME=${HBASE_HOME}" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hbase_hosts echo "PATH='\$PATH':${HBASE_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hbase_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"
	
	echo "Create Zookeeper directory for all hosts..."
	pdsh -w ^hbase_hosts mkdir -p  "${HBASE_HOME}"/zookeeper
	
	echo "Copying Hadoop config file to all hosts..."
	pdcp -w ^hbase_hosts "${HADOOP_HOME}/etc/hadoop/core-site.xml" "${HBASE_HOME}/conf/"
	pdcp -w ^hbase_hosts "${HADOOP_HOME}/etc/hadoop/hdfs-site.xml" "${HBASE_HOME}/conf/"
	
	echo "Copying HBase config file to all hosts..."
	pdcp -w ^hbase_hosts "${INSTALL_HOME}/conf/hbase-env.sh" "${HBASE_HOME}/conf/"
	pdcp -w ^hbase_hosts "${INSTALL_HOME}/conf/hbase-site.xml" "${HBASE_HOME}/conf/"
	pdcp -w ^hbase_hosts "${INSTALL_HOME}/conf/regionservers" "${HBASE_HOME}/conf/"
	
	echo "Installing HBase to all hosts success ..."
}

PARAMS=$#
if [ $PARAMS != 6 ] ; then
    echo "Usage:install-hbase [install] [APP_HOME] [HBASE_FILE] [HBASE_VERSION] [HADOOP_HOME] [USER]"
    exit
fi

if [ $PARAMS == 6 ] && [ $1 == "install" ] ; then
    echo "install hbase $2 $3 $4 $5 $6 ........."
    install $2 $3 $4 $5 $6
    exit
fi

echo "Usage:install-hbase [install] [APP_HOME] [HBASE_FILE] [HBASE_VERSION] [USER]"