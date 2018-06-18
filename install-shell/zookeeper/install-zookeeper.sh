#!/bin/bash


INSTALL_HOME=$(cd "$(dirname "$0")";pwd)

set_myid() {
  ID_LIST=$1
    IFS=',' read -r -a server_array <<< "$ID_LIST"
    for server_item in "${server_array[@]}"
    do
        IFS=':' read -r -a id_array <<< "$server_item"
        echo "Set myid:${id_array[1]} for ZOOKEEPER to server:${id_array[0]} ..........."
        pdsh -w "${id_array[0]}" echo "${id_array[1]}" \> "${ZOOKEEPER_HOME}"/data/myid
    done
}

install() {
    APP_HOME=$1
    ZOOKEEPER_FILE=$2
    ZOOKEEPER_VERSION=$3
    ID_LIST=$4
    USER_HOME=/home/"$5"/
    ZOOKEEPER_HOME="${APP_HOME}/zookeeper"

	echo "Copying Zookeeper $ZOOKEEPER_VERSION to all hosts..."
	pdcp -w ^zookeeper_hosts "${ZOOKEEPER_FILE}" "${APP_HOME}/"
	pdsh -w ^zookeeper_hosts tar -zxf "${APP_HOME}/${ZOOKEEPER_FILE}" -C "${APP_HOME}/"
    pdsh -w ^zookeeper_hosts rm -rf "${APP_HOME}/zookeeper"
	pdsh -w ^zookeeper_hosts ln -s "${APP_HOME}/zookeeper-${ZOOKEEPER_VERSION}" "${APP_HOME}/zookeeper"
	pdsh -w ^zookeeper_hosts mkdir -p "${ZOOKEEPER_HOME}"/data
	pdsh -w ^zookeeper_hosts mkdir -p "${ZOOKEEPER_HOME}"/logs

    echo "Add ZOOKEEPER_HOME to PATH to all hosts..."	
	pdsh -w ^zookeeper_hosts echo "export ZOOKEEPER_HOME=${APP_HOME}/zookeeper" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^zookeeper_hosts echo "PATH='\$PATH':${ZOOKEEPER_HOME}/bin" \>\> "${USER_HOME}/.bash_profile"
	pdsh -w ^zookeeper_hosts echo "export PATH" \>\> "${USER_HOME}/.bash_profile"

    echo "Copying ZOOKEEPER config file to all hosts..."	
	pdcp -w ^zookeeper_hosts "${INSTALL_HOME}/conf/zoo.cfg" "${ZOOKEEPER_HOME}/conf/"
	
    echo "Set myid:$ID_LIST for ZOOKEEPER to all hosts..."
    pdsh -w ^zookeeper_hosts touch "${APP_HOME}"/zookeeper/data/myid
    set_myid $ID_LIST
#        echo "Start ZOOKEEPER service on all hosts..."
#        pdsh -w ^zookeeper_hosts "${ZOOKEEPER_HOME}"/bin/zkServer.sh start

#        echo "Check ZOOKEEPER service on all hosts..."
#        pdsh -w ^zookeeper_hosts "${JAVA_HOME}"/bin/jps
        echo "Install ZOOKEEPER service on all hosts success..."
}

checkconfig_on() {
    ZOOKEEPER_HOME=$1

    echo "Check config on for zookeeper ........"
    pdsh -w ^zookeeper_hosts echo "${ZOOKEEPER_HOME}/bin/zkServer.sh start" | awk {'print $2 " " $3'} | sudo tee --append /etc/rc.d/rc.local \> /dev/null
}

PARAMS=$#
if [ $PARAMS != 6 ] && [ $PARAMS != 2 ] ; then
    echo "Usage:install-zookeeper [install|checkconfigon] [APP_HOME|ZOOKEEPER_HOME] [ZookeeperFile] [ZOOKEEPER_VERSION] [MYID_LIST:HOSTNAME:ID,HOSTNAME:ID] [USER]"
    exit
fi

if [ $PARAMS == 6 ] && [ $1 == "install" ] ; then
    echo "install zookeeper $2 $3 $4 $5 $6 ........."
    install $2 $3 $4 $5 $6
    exit
fi

if [ $PARAMS == 2 ] && [ $1 == "checkconfigon" ] ; then
    echo "check config on $2 ........."
    checkconfig_on $2
    exit
fi

echo "Usage:install-zookeeper [install|checkconfigon] [APP_HOME|ZOOKEEPER_HOME] [ZookeeperFile] [ZOOKEEPER_VERSION] [MYID_LIST:HOSTNAME:ID,HOSTNAME:ID] [USER]"