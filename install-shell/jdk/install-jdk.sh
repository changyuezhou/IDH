#!/bin/bash

INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

install() {
    APP_HOME=$1
    JDK_INSTALL_FILE=$2
    JAVA_VERSION=$3
    USER_HOME=/home/"$4"/
    
    JAVA_HOME="${APP_HOME}/jdk"
    
	echo "Copying JDK ${JAVA_VERSION} to all hosts..."
	pdcp -w ^jdk_hosts "${JDK_INSTALL_FILE}" "${APP_HOME}"

	echo "Installing JDK ${JAVA_VERSION} on all hosts..."
	pdsh -w ^jdk_hosts tar zxf "${APP_HOME}/${JDK_INSTALL_FILE}" -C "${APP_HOME}/"
        pdsh -w ^jdk_hosts rm -rf "${JAVA_HOME}"
	pdsh -w ^jdk_hosts ln -s "${JAVA_HOME}${JAVA_VERSION}" "${JAVA_HOME}"

	echo "Set JAVA_HOME env to all hosts..."
	pdsh -w ^jdk_hosts echo "export JAVA_HOME=${JAVA_HOME}" \>\> "${USER_HOME}"/.bash_profile
	pdsh -w ^jdk_hosts echo "PATH='\$PATH':${JAVA_HOME}/bin" \>\> "${USER_HOME}"/.bash_profile
	pdsh -w ^jdk_hosts echo "export PATH" \>\> "${USER_HOME}"/.bash_profile

    echo "Installing JDK ${JAVA_VERSION} on all hosts success"
}

PARAMS=$#
if [ $PARAMS != 5 ] ; then
    echo "Usage:install-jdk [install] [APP_HOME] [JDK_FILE] [JAVA_VERSION] [USER]"
    exit
fi

if [ $PARAMS == 5 ] && [ $1 == "install" ] ; then
    echo "install jdk $2 $3 $4 $5........."
    install $2 $3 $4 $5
    exit
fi

echo "Usage:install-jdk [install] [APP_HOME] [JDK_FILE] [JAVA_VERSION] [USER]"