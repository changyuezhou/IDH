#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

install() {
    APP_HOME=$1
    SPARK_FILE=$2
    SPARK_VERSION=$3
    HADOOP_VERSION=$4
    HIVE_HOME=$5
    USER_HOME=/home/"$6"/
    
    SPARK_HOME="${APP_HOME}"/spark

	echo "Copying Spark $SPARK_VERSION to all hosts..."
	pdcp -w ^spark_hosts "$SPARK_FILE" "${APP_HOME}/"
	pdsh -w ^spark_hosts tar -zxvf "${APP_HOME}/${SPARK_FILE}" -C "${APP_HOME}/" \> /dev/null
	pdsh -w ^spark_hosts rm -rf "${SPARK_HOME}"
	pdsh -w ^spark_hosts ln -s "${APP_HOME}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" "${SPARK_HOME}"
	
	echo "Set SPARK_HOME env to all hosts..."
	pdsh -w ^spark_hosts echo "export SPARK_HOME=${SPARK_HOME}" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^spark_hosts echo "PATH='\$PATH':${SPARK_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^spark_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"
	
	echo "Copying Spark config file to all hosts..."
	pdcp -w ^spark_hosts "${INSTALL_HOME}/conf/spark-env.sh" "${SPARK_HOME}/conf/"
	pdcp -w ^spark_hosts "${INSTALL_HOME}/conf/slaves" "${SPARK_HOME}/conf/"
	
	echo "Link Hive conf file to Spark for all hosts ..."
    pdsh -w ^spark_hosts rm -rf "${SPARK_HOME}"/conf/hive-site.xml
	pdsh -w ^spark_hosts ln -s ${HIVE_HOME}/conf/hive-site.xml "${SPARK_HOME}"/conf/hive-site.xml
	
	echo "Copying libs file to all hosts ...."
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/hbase-protocol-1.2.6.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/hbase-common-1.2.6.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/hbase-client-1.2.6.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/hbase-server-1.2.6.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/htrace-core-3.1.0-incubating.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/metrics-core-2.2.0.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/hive-hbase-handler-2.1.0.jar "${SPARK_HOME}"/jars/
    pdcp -w ^spark_hosts "${INSTALL_HOME}"/lib/mysql-connector-java-5.1.46-bin.jar "${SPARK_HOME}"/jars/
	
	echo "Installing Spark to all hosts success ..."
}

PARAMS=$#
if [ $PARAMS != 7 ]; then
    echo "Usage:install-spark install [APP_HOME] [SPARK_FILE] [SPARK_VERSION] [HADOOP_VERSION] [HIVE_HOME] [USER]"
    exit
fi

if [ $PARAMS == 7 ] && [ $1 == "install" ] ; then
    echo "install spark $2 $3 $4 $5 $6 $7 ........."
    install $2 $3 $4 $5 $6 $7
    exit
fi

echo "Usage:install-spark install [APP_HOME] [SPARK_FILE] [SPARK_VERSION] [HADOOP_VERSION] [HIVE_HOME] [USER]"