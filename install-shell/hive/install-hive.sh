#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)
MYSQL_CONNECTOR_FILE=mysql-connector-java-5.1.46.jar

install() {
   APP_HOME=$1
   HIVE_FILE=$2
   HIVE_VERSION=$3
   USER_HOME=/home/"$4"/
   
   HIVE_HOME="${APP_HOME}"/hive

	echo "Copying HBase $HIVE_VERSION to all hosts..."
	pdcp -w ^hive_hosts "${HIVE_FILE}" "${APP_HOME}/"
	pdsh -w ^hive_hosts tar -zxf "${APP_HOME}/${HIVE_FILE}" -C "${APP_HOME}/"
	pdsh -w ^hive_hosts rm -rf "${HIVE_HOME}"
	pdsh -w ^hive_hosts ln -s "${APP_HOME}/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}"
	
	echo "Set HIVE_HOME env to all hosts..."
	pdsh -w ^hive_hosts echo "export HIVE_HOME=${HIVE_HOME}" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hive_hosts echo "PATH='\$PATH':${HIVE_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^hive_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"
	
	echo "Copying Hive config file to all hosts..."
	pdcp -w ^hive_hosts "${INSTALL_HOME}/conf/hive-env.sh" "${HIVE_HOME}/conf/"
	pdcp -w ^hive_hosts "${INSTALL_HOME}/conf/hive-site.xml" "${HIVE_HOME}/conf/"

    echo "Copying Mysql connector jar file to all hosts..."
    pdcp -w ^hive_hosts "${MYSQL_CONNECTOR_FILE}" "${HIVE_HOME}/lib/"
    
	echo "Installing Hive to all hosts success ..."
}

PARAMS=$#
if [ $PARAMS != 5 ] ; then
    echo "Usage:install-hive [install] [APP_HOME] [HIVE_FILE] [HIVE_VERSION] [USER]"
    exit
fi

if [ $PARAMS == 5 ] && [ $1 == "install" ] ; then
    echo "install hive $2 $3 $4 $5 ........."
    install $2 $3 $4 $5
    exit
fi

echo "Usage:install-hive [install] [APP_HOME] [HIVE_FILE] [HIVE_VERSION] [USER]"