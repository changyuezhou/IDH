#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

install() {
   APP_HOME=$1
   KAFKA_FILE=$2
   KAFKA_VERSION=$3
   USER_HOME=/home/"$4"/
   
   KAFKA_HOME="${APP_HOME}"/kafka

	echo "Copying Kafka $KAFKA_VERSION to all hosts..."
	pdcp -w ^kafka_hosts "${KAFKA_FILE}" "${APP_HOME}/"
	pdsh -w ^kafka_hosts tar -zxf "${APP_HOME}/${KAFKA_FILE}" -C "${APP_HOME}/"
	pdsh -w ^kafka_hosts rm -rf "${KAFKA_HOME}"
	pdsh -w ^kafka_hosts ln -s "${APP_HOME}/kafka_${KAFKA_VERSION}" "${KAFKA_HOME}"
	
	echo "Set KAFKA_HOME env to all hosts..."
	pdsh -w ^kafka_hosts echo "export KAFKA_HOME=${KAFKA_HOME}" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^kafka_hosts echo "PATH='\$PATH':${KAFKA_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^kafka_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"
	
	echo "Create Kafka logs directory for all hosts..."
	pdsh -w ^kafka_hosts mkdir -p "${KAFKA_HOME}"/logs
	
	echo "Copying Kafka config file to all hosts..."
	pdcp -w ^kafka_hosts "${INSTALL_HOME}/conf/server.properties" "${KAFKA_HOME}/config/"

	echo "Installing Kafka to all hosts success ..."
}

PARAMS=$#
if [ $PARAMS != 5 ] ; then
    echo "Usage:install-kafka [install] [APP_HOME] [KAFKA_FILE] [KAFKA_VERSION] [USER]"
    exit
fi

if [ $PARAMS == 5 ] && [ $1 == "install" ] ; then
    echo "install kafka $2 $3 $4 $5 ........."
    install $2 $3 $4 $5
    exit
fi

echo "Usage:install-kafka [install] [APP_HOME] [KAFKA_FILE] [KAFKA_VERSION] [USER]"