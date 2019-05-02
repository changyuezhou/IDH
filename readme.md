#  集群安装部署手册
-------------------
## [1 关于文档](#about_doc)
## [2 背景知识](#background)
## [3 准备工作](#prepare_work)
### [3.1 安装 expect](#install_expect)
### [3.2 安装 pdsh](#install_pdsh)
### [3.3 超级权限用户免密登录](#root_create_ssh_key)
### [3.4 集群安装 expect](#install_all_expect)
### [3.5 集群安装 pdsh](#install_all_pdsh)
### [3.6 配置Hosts](#hosts_config)
### [3.7 创建用户](#create_user)
### [3.8 创建免密登录](#create_ssh_key)
### [3.9 创建挂载数据盘目录](create_mount_dir#)
### [3.10 挂载数据盘（可选）](#mount_disk)
### [3.11 防火墙设置（可选）](#set_firewalld)
### [3.12 规划集群机器角色](#set_role)
## [4 MySQL 安装(Hive Metastore)](#mysql_install)
### [4.1 单机安装](#one_install)
### [4.2 集群安装](#multi_install)
## [5 JDK 安装](#jdk_install)
## [6 Zookeeper 安装](#zookeeper_install)
## [7 Hadoop 安装](#hadoop_install)
## [8 HBase 安装](#hbase_install)
## [9 Hive 安装](#hive_install)
## [10 Spark 安装](#spark_install)
## [11 Kafka 安装](#kafka_install)
## [12 Flume 安装](#flume_install)

-------------------
## 1. 关于文档 <a name="about_doc"/>
   本文档作为售前运维，技术运维，技术研发安装部署集群参考手册，提供了整个集群安装部署需要注意的事项和部署方法.

## 2. 背景知识 <a name="background"/>
   为了让项目成员从繁琐的集群配置和安装命令中解脱出来，降低集群安装运维成本，整理出这份文档,用以标准化流程.

## 3. 准备工作 <a name="prepare_work"/>
   选择集群服务器中某台服务器作为安装跳板机,以下简称跳板机，所有的安装文件都将会存放在此台服务器中.
### 3.1 安装 expect <a name="install_expect"/>
   * 1) 超级权限用户登录跳板机
   
   ```
   ssh -p 22 user@127.0.0.1
   ```
   
   * 2) install
   
   ```
   sudo yum install -y expect
   ```

### 3.2 安装 pdsh <a name="install_pdsh"/>
   * 1) 超级权限用户登录跳板机
   
   ```
   ssh -p 22 user@127.0.0.1
   ```
   
   * 2) install epel
   
   ```
   sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   ```
   
   * 3) install
   
   ```
   sudo yum install -y pdsh
   ```   

### 3.3 超级权限用户免密登录 <a name="root_create_ssh_key"/>
   * 1) 超级权限用户登录跳板机,进入安装目录中的install-shell/initial目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/initial
   ```
   
   * 2) 执行命令

   ```
   expect initial.exp distSSHKey 127.0.0.1,127.0.0.2(Service List) user user_password
   ```
   
### 3.4 集群安装 expect <a name="install_all_expect"/>
   * 1) 超级权限用户登录跳板机,进入install-shell目录

   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```
      
   * 2) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
      
   * 4) install
   
   ```
   pdsh -w ^all_host sudo yum install -y expect   
   ```
   
### 3.5 集群安装 pdsh <a name="install_all_pdsh"/>
   * 1) 超级权限用户登录跳板机,进入install-shell目录

   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```
      
   * 2) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
      
   * 4) install epel
   
   ```
   sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   ```
   
   * 5) install pdsh
   
   ```
   sudo yum install -y pdsh
   ```

### 3.6 配置Hosts <a name="hosts_config"/>
   * 1) 超级权限用户登录服务器，进入install-shell目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```
      
   * 2) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出

   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
   * 4) 拷贝本地 hosts
   
   ```
   cp /etc/hosts ./
   ```
   
   * 5) 编辑 hosts 文件，将集群服务器对应的 ip地址和hostname 都加进该文件,并保存退出
   
   ```
   172.23.0.21	Hadoop
   172.23.0.22	HBase
   172.23.0.23 Hive   
   ```
   
   * 6) 部署到集群
   
   ```
   pdcp -w ^all_hosts hosts /etc/hosts
   ```
   
### 3.7 创建用户（可选）<a name="create_user"/>
   * 1) 超级权限用户登录跳板机,进入安装目录中的install-shell/initial目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/initial
   ```
      
   * 2) 执行命令
   
   ```
   expect initial.exp userCreate 127.0.0.1,127.0.0.2(Server List) root(超级权限用户) root_password user user_password user_group
   ```
   
### 3.8 创建免密登录 <a name="create_ssh_key"/>
   * 1) 上传安装文件到3.7步骤创建的用户目录下
   
   ```
   scp -P 2228 -r install-shell suxin@127.0.0.1:/home/suxin/
   ```
   
   * 2) 用3.7步骤创建的用户登录跳板机,进入安装目录中的install-shell/initial目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/initial
   ```
      
   * 3) 执行命令
   
   ```
   expect initial.exp distSSHKey 127.0.0.1,127.0.0.2(Server List) user user_password
   ```
   
   * 4) 初始化 ssh known keys
   
   ```
   expect initial.exp initKnownKey HadoopRM,HadoopNN(HOSTNAME_LIST) user user_password
   ```
   
   * 5) 重复1 - 4步骤，直至完成所有服务器

### 3.9 创建挂载数据盘目录 <a name="create_mount_dir"/>
   * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```
      
   * 2) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出

   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
   * 4) 创建挂载目录
   
   ```
   pdsh -w ^all_hosts mkdir -p /home/${user}/application
   ```
   
### 3.10 挂载数据盘（可选）<a name="mount_disk"/>
   * 1) 超级权限用户登录服务器
   
   ```
   ssh -p 22 user@127.0.0.1
   ```
      
   * 2) sudo lsblk
   
   ```
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0           2:0    1    4K  0 disk 
sda           8:0    0   32G  0 disk 
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0   31G  0 part 
  ├─cl-root 253:0    0 27.8G  0 lvm  /
  └─cl-swap 253:1    0  3.2G  0 lvm  [SWAP]
sdb           8:16   0    2T  0 disk /home/apps/application
sr0          11:0    1 1024M  0 rom
   ```
      
   * 3) 格式化数据盘
   
   ```
   sudo mkfs.ext4 ${步骤2看到的数据盘标识，例：/dev/sdb,/dev/sdc} 
   ```
   
   * 4) 按步骤选择Y即可
   
   ```
mke2fs 1.42.9 (28-Dec-2013)
/dev/sdb is entire device, not just one partition!
Proceed anyway? (y,n)   
   ```
   * 5) 重复1 - 4步骤，直至完成所有服务器
   
   * 6) 超级权限用户登录跳板机,进入install-shell目录
   
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```
      
   * 7) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 8) 将所有服务器写入文件，一行一个服务器，并保存退出 
   
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
      
   * 9) 执行命令
   
   ```
   pdsh -w ^all_hosts sudo mount ${步骤2看到的数据盘标识，例：/dev/sdb,/dev/sdc}  /home/${USER}/application
   ```
   
   * 10) 改变目录属主
   
   ```
   pdsh -w ^all_hosts sudo chown ${USER}:${USER_GROUP} /home/${USER}/application
   ```
   
   * 11) 查看数据盘 UUID (需要每台服务器独立操作的步骤)
   
   ```
   sudo blkid 
   ```
   
   ```
/dev/sdb: UUID="7348f362-bba7-4b2f-b55f-2fdb4c3a9a41" TYPE="ext4" 
/dev/sda1: UUID="f3a6907b-7ec0-4ad4-be11-d46928592754" TYPE="xfs" 
/dev/sda2: UUID="8GfyzU-aEw6-4WX2-TL0R-gqT0-C1Qg-JvHBST" TYPE="LVM2_member" 
/dev/mapper/cl-root: UUID="1ca5c173-766f-4020-9cd0-c02a228720e8" TYPE="xfs" 
/dev/mapper/cl-swap: UUID="f6361ffa-c19c-4507-a99f-17d32705a793" TYPE="swap"
   ```
   
   * 12) 编辑 /etc/fstat
   
   ```
   sudo vim /etc/fstab
   ```
   
   * 13) 将如下行加到文件
   
   ```
   UUID=${数据盘的UUID}  /home/${USER}/application ext4 defaults 0 0
   ```
   
   ```
#
# /etc/fstab
# Created by anaconda on Wed Jan  3 10:52:36 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/cl-root     /                       xfs     defaults        0 0
UUID=f3a6907b-7ec0-4ad4-be11-d46928592754 /boot                   xfs     defaults        0 0
/dev/mapper/cl-swap     swap                    swap    defaults        0 0
UUID=7348f362-bba7-4b2f-b55f-2fdb4c3a9a41 /home/apps/application ext4 defaults 0 0
   ```
   
   * 14) 重复11 - 13步骤，直至完成所有服务器

### 3.11 防火墙设置（可选）<a name="set_firewalld"/>
   * 1) 超级权限用户登录服务器
   
   ```
   ssh -p 22 user@127.0.0.1
   ```
      
   * 2) 编辑文件
   
   ```
   vi all_hosts
   ```
   
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
      
   * 4) 停止防火墙
   
   ```
   pdsh -w ^all_hosts sudo systemctl stop firewalld.service
   ```
   
   * 5) 关闭自启动
   
   ```
   pdsh -w ^hadoop_cluster sudo systemctl disable firewalld.service
   ```
   
   * 6) 如果不能关闭防火墙，可以使用如下命令添加放行端口号
   
   ```
   pdsh -w ^hadoop_cluster sudo firewall-cmd --zone=public --add-port=${PORT}/tcp --permanent
   ```
   
   * 7) 如果是步骤6 执行如下命令使防火墙端口放行命令生效
   
   ```
   pdsh -w ^hadoop_cluster sudo firewall-cmd --reload
   ```
   
### 3.12 规划集群机器角色 <a name="set_role"/>
   * 1) Zookeeper 集群服务器分配（MYID）
   * 2) kafka 集群服务器分配
   * 3) Flume 集群服务器分配
   * 4) ElasticSearch 集群服务器分配
   * 5) Hadoop 集群服务器分配（RM,NM,NN,SNN,DN,JobHistory）
   * 6) HBase 集群服务器分配（Master,RegionServer）
   * 7) Hive 服务器分配
   * 8) Spark 集群服务器分配 (Master, Slaves)
   
   
## 4. MySQL 安装 <a name="mysql_install"/>
### 4.1 单机安装 <a name="one_install"/>
   ###  Step 1. Add MariaDB Yum Repository
   *   1) 编辑安装库
   
   ```
   sudo vi /etc/yum.repos.d/MariaDB.repo
   ```
   
   *   2) 添加如下内容进文件,并保存退出
   
   ```
   [mariadb]
   name = MariaDB
   baseurl = http://yum.mariadb.org/10.1/centos7-amd64
   gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
   gpgcheck=1   
   ```

   ###  Step 2. Install MariaDB in CentOS 7
   * 1) 安装组
   
   ```
   sudo yum groupinstall -y mariadb*
   ```
   
   * 2) 启动 mariadb
   
   ```
   sudo systemctl start mariadb
   ```
   
   * 3) 开启自启动
   
   ```
   sudo systemctl enable mariadb
   ```
   
   * 4) 查看状态
   
   ```
   sudo systemctl status mariadb
   ```
   
   ### Step 3. Secure MariaDB in CentOS 7
   * 1) 设置
   
   ```
   mysql_secure_installation
   ```
   
   ```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] Y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!   
   ```
   
### 4.2 集群安装 MySQL <a name="multi_install"/>
  * 1) * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell
   ```

   * 2) 编辑文件 mysql_hosts
   
   ```
   vi mysql_hosts
   ```
   
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出

   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
        
  * 4) 执行命令
  
  ```
  pdsh -w ^mysql_hosts "echo "[mariadb]" | awk {'print $2'} | sudo tee --append /etc/yum.repos.d/MariaDB.repo \> /dev/null"
  ```
  
  ```
  pdsh -w ^mysql_hosts "echo "name = MariaDB" | awk {'print $2 " " $3 " " $4'} | sudo tee --append /etc/yum.repos.d/MariaDB.repo \> /dev/null"
  ```
  
  ```
  pdsh -w ^mysql_hosts "echo "baseurl = http://yum.mariadb.org/10.2/centos7-amd64" | awk {'print $2 " " $3 " " $4'} | sudo tee --append /etc/yum.repos.d/MariaDB.repo \> /dev/null"
  ```
  
  ```
  pdsh -w ^mysql_hosts "echo "gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" | awk {'print $2 " " $3 " " $4'} | sudo tee --append /etc/yum.repos.d/MariaDB.repo \> /dev/null"
  ```
  
  ```
  pdsh -w ^mysql_hosts "echo "gpgcheck = 1" | awk {'print $2 " " $3 " " $4'} | sudo tee --append /etc/yum.repos.d/MariaDB.repo \> /dev/null"
  ```
  
  ```
  pdsh -w ^mysql_hosts sudo groupinstall -y mariadb*
  ```
  
  * 5) 验证
  
  ```
  ssh -p 22 user@INSTALL_MYSQL
  
  [apps@Elastic ~]$ mysql --version
  mysql  Ver 15.1 Distrib 10.2.15-MariaDB, for Linux (x86_64) using readline 5.1
  ```
   
## 5 JDK 安装 <a name="jdk_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/jdk目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/jdk
   ```
      
   * 2) 编辑文件 jdk_hosts
   
   ```
   vi jdk_hosts
   ```
   
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出

   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
     
  * 4) 执行命令
  
  ```
  install-jdk [install] [APP_HOME] [JDK_FILE] [JAVA_VERSION] [USER]
  ```
  
  ```
  ./install-jdk install /home/suxin/test_install jdk-8u171-linux-x64.tar.gz 1.8.0_171 suxin
  
install jdk /home/suxin/test_install jdk-8u171-linux-x64.tar.gz 1.8.0_171 suxin.........
Copying JDK 1.8.0_171 to all hosts...
Installing JDK 1.8.0_171 on all hosts...
Set JAVA_HOME env to all hosts...
Installing JDK 1.8.0_171 on all hosts success  
  ```
  
  * 5) 可选： 用3.7步骤创建的用户登录跳板机, 输入jps命令，如果能运行则安装成功.
  
  ```
  94037 Jps
  ```
  
## 6 Zookeeper 安装 <a name="zookeeper_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/zookeeper目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/zookeeper
   ```

   * 2) 编辑文件 zookeeper_hosts
   
   ```
   vi zookeeper_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
  * 4) 编辑文件 conf/zoo.cfg
  
  ```
  vi cond/zoo.cfg
  ```
  
  * 5) 修改或添加配置
  
  ```
  # The directory where the snapshot is stored.
  
  dataDir=${ZOOKEEPER_HOME}/data
  dataLogDir=${ZOOKEEPER_HOME}/logs  
  ```
  
  ```
  # To configure a ZooKeeper instance you add the following parameter to the file "zoo.cfg":
  # server.<id> = <zk_host_address>:<zk_port_1>:<zk_port_2>[:<zk_role>];[<client_port_address>:]<client_port>
  
  # example:
  server.1=AZ-TEST-DEV4:2888:3888
  server.2=AZ-TEST-DEV2:2888:3888
  server.3=AZ-TEST-DEV3:2888:3888  
  
  ```
  
  * 6) 执行命令
  
  ```
  install-zookeeper [install] [APP_HOME] [ZookeeperFile] [ZOOKEEPER_VERSION] [MYID_LIST:HOSTNAME:ID,HOSTNAME:ID] [USER]
  ```
  
  ```
  install zookeeper /home/suxin/test_install zookeeper-3.4.10.tar.gz 3.4.10 127.0.0.1:1 suxin .........
  
  Copying Zookeeper 3.4.10 to all hosts...
  Add ZOOKEEPER_HOME to PATH to all hosts...
  Copying ZOOKEEPER config file to all hosts...
  Set myid:127.0.0.1:1 for ZOOKEEPER to all hosts...
  Set myid:1 for ZOOKEEPER to server:127.0.0.1 ...........
  Install ZOOKEEPER service on all hosts success...  
  ```
  
  * 7) 可选：增加服务自启动
  
  ```
  install-zookeeper [checkconfigon] [ZOOKEEPER_HOME]
  ```
  
  ```
  ./install-zookeeper.sh checkconfigon /home/suxin/test_install/zookeeper
  
  check config on /home/suxin/test_install/zookeeper .........
  Check config on for zookeeper ........
  /home/suxin/test_install/zookeeper/bin/zkServer.sh start
  
  ```
  
  * 8) 用3.7步骤创建的用户登录Zookeeper服务器
  
   ```
   ssh -p 22 user@127.0.0.1
   ```
     
  * 9) 执行命令
  
  ```
  ${ZOOKEEPER_HOME}/bin/zkServer.sh start
  ```
  
  * 10) 验证,看到 QuorumPeerMain 进程表示成功
  
  ```
  ${JAVA_HOME}/bin/jps 
  ```
  
   ```
   90448 QuorumPeerMain
   26577 Jps
   ```
   
  * 10) 重复6 - 8步骤，直至完成zookeeper集群所有服务器.
  
## 7 Hadoop 安装 <a name="hadoop_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/hadoop目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/hadoop
   ```

   * 2) 编辑文件 hadoop_hosts
   
   ```
   vi hadoop_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
  * 4) 编辑文件 conf/core-site.xml
  
  ```
  <property>
    <name>fs.default.name</name>
    <value>hdfs://${APP_NAME}</value>
  </property>
  ``` 
  
  ```
  <property>
    <name>ha.zookeeper.quorum</name>
    <value>${IP1}:${PORT},${IP2}:${PORT},${IP3}:${PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>file:${DIRECTORY_PATH}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>hadoop.tmp.dir</name>
    <value>file:${HADOOP_TMP}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>fs.trash.interval</name>
    <value>${TRASH_INTERVAL}</value>
  </property>
  ```

  * 5) 编辑文件 conf/hadoop-env.sh
  
  ```
  # set JAVA_HOME
  
  export JAVA_HOME=${JAVA_HOME}
  ```
  
  * 6) 编辑文件 conf/hdfs-site.xml
  
  ```
  <property>
    <name>dfs.nameservices</name>
    <value>${APP_NAME}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
    <value>false</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.ha.namenodes.${APP_NAME}</name>
    <value>nn1,nn2</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.rpc-address.${APP_NAME}.nn1</name>
    <value>${NAME_NODE1}:${NN1_RPC_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.rpc-address.${APP_NAME}.nn2</name>
    <value>${NAME_NODE2}:${NN2_RPC_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.http-address.${APP_NAME}.nn1</name>
    <value>${NAME_NODE1}:${NN1_HTTP_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.http-address.${APP_NAME}.nn2</name>
    <value>${NAME_NODE2}:${NN2_HTTP_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://${NodeManage1}:${QJOURNAL_PORT};${NodeManage2}:${QJOURNAL_PORT};${NodeManage3}:${QJOURNAL_PORT}/${APP_NAME}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>${JOURNAL_DIRECOTRY}</value>
  </property>
  ```
  
  ```
  <property>
    <name>dfs.client.failover.proxy.provider.${APP_NAME}</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.ha.fencing.methods</name>
    <value>sshfence</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:${NAME_NODE_DIR}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:${DATA_NODE_DIR}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.replication</name>
    <value>${REPLICATION}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.permissions.superusergroup</name>
    <value>staff</value>
  </property>  
  ```
  
  ```
  <property>
    <name>dfs.permissions.enabled</name>
    <value>false</value>
  </property>  
  ```
  
  * 7) 编辑 conf/mapred-site.xml
  
  ```
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.jobtracker.http.address</name>
    <value>${RESOURCE_MANAGER}:${JOBTRACKER_HTTP_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.jobhisotry.address</name>
    <value>${JOBHISTORY_NODE}:${JOBHISTORY_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>${JOBHISTORY_NODE}:${JOBHISTORY_WEBAPP_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.jobhistory.done-dir</name>
    <value>/jobhistory/done</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.intermediate-done-dir</name>
    <value>/jobhisotry/done_intermediate</value>
  </property>  
  ```
  
  ```
  <property>
    <name>mapreduce.job.ubertask.enable</name>
    <value>true</value>
  </property>  
  ```
  
  * 8) 编辑文件 conf/yarn-site.xml
  
  ```
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>${RESOURCE_MANAGER}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.resourcemanager.address</name>
    <value>${RESOURCE_MANAGER}:${RM_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>${RESOURCE_MANAGER}:${SCHEDULER_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.resourcemanager.resource-tracker.address</name>
    <value>${RESOURCE_MANAGER}:${RESOURCE_TRACKER_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.resourcemanager.admin.address</name>
    <value>${RESOURCE_MANAGER}:${ADMIN_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>${RESOURCE_MANAGER}:${WEB_APP_PORT}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.log-aggregation.retain-seconds</name>
    <value>${RETAIN_SECONDS}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.log-aggregation.retain-check-interval-seconds</name>
    <value>${RETAIN_CHECK_INTERVAL}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.nodemanager.remote-app-log-dir</name>
    <value>${REMOTE_APP_LOG_DIR}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>yarn.nodemanager.remote-app-log-dir-suffix</name>
    <value>logs</value>
  </property>  
  ```
  
  * 9) 编辑文件 conf/slaves
  
  ```
  # hostname
  
  172.23.0.21
  172.23.0.22
  172.23.0.23  
  ```
  
  * 10) 执行安装命令
  
  ```
  install-hadoop install [APP_HOME] [HADOOP_FILE] [HADOOP_VERSION] [USER]
  ```
  
  ```
  ./install-hadoop.sh install /home/suxin/test_install hadoop-2.8.3.tar.gz 2.8.3 suxin
  
  install hadoop /home/suxin/test_install hadoop-2.8.3.tar.gz 2.8.3 suxin .........
  Copying Hadoop 2.8.3 to all hosts...
  Set HADOOP_HOME env to all hosts...
  Copying Hadoop config file to all hosts...
  Installing Hadoop to all hosts success ...  
  ```
  
  * 11) 初始化
  
  ```
  install-hadoop initial [NameNode] [SecondaryNameNode] [ResourceManager]
  ```
  
  ```
  ./install-hadoop.sh initial Hadoop HBase Hadoop
  
  
  initial hadoop NameNode:Hadoop SecondaryNameNode:HBase ResourceManager:Hadoop .........
  Initial NameNode:  SecondaryNameNode: HBase ResourceManager:Hadoop ...
  NameNode: Hadoop start .................
  Hadoop: starting namenode, logging to /home/apps/application/cluster/hadoop-2.8.3/logs/hadoop-apps-namenode-Hadoop.out
  NameNode: HBase bootstrapStandby .................
  HBase: 18/06/14 23:19:36 INFO namenode.NameNode: STARTUP_MSG: 
  HBase: /************************************************************
  HBase: STARTUP_MSG: Starting NameNode
  HBase: STARTUP_MSG:   user = apps
  HBase: STARTUP_MSG:   host = HBase.sh.21vevdc.com/172.23.0.22
  HBase: STARTUP_MSG:   args = [-bootstrapStandby]  
  ```
  
  * 12) 关闭服务
  
  ```
  ssh -p 22 ResourceManage
  ${HADOOP_HOME}/sbin/stop-all.sh
  ```
  
  * 13) 启动服务
  
  ```
  ssh -p 22 ResourceManage
  ${HADOOP_HOME}/sbin/start-all.sh  
  ```
  
  * 14) 验证,出现如下进程表示成功
  
  ```
  ssh -p 22 ResourceManage
  
  jps
  ```
  
  ```
  40550 DataNode
  40778 JournalNode
  41229 NodeManager
  40431 NameNode
  60312 Jps
  40987 DFSZKFailoverController
  41116 ResourceManager  
  ```
  
## 8 HBase 安装 <a name="hbase_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/hbase目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/hbase
   ```

   * 2) 编辑文件 hbase_hosts
   
   ```
   vi hbase_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
  * 4) 编辑 conf/hbase-env.sh
  
  ```
  export JAVA_HOME=${JAVA_HOME}
  ``` 
  
  * 5) 编辑 conf/hbase-site.xml
  
  ```
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://${NAME_NODE}:${NN_PORT}/hbase</value>
  </property>  
  ```

  ```
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>  
  ```
  
  ```
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>${ZOOKEEPER_IP1},${ZOOKEEPER_IP2},${ZOOKEEPER_IP3}</value>
  </property>  
  ```
  
  ```
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>${HBASE_HOME}/zookeeper</value>
  </property>  
  ```
  
  * 6) 编辑 conf/regionservers
  
  ```
  172.23.0.21
  172.23.0.22
  172.23.0.23  
  ```
  
  * 7) 安装
  
  ```
  install-hbase [install] [APP_HOME] [HBASE_FILE] [HBASE_VERSION] [HADOOP_HOME] [USER]
  ```
  
  ```
  ./install-hbase.sh install /home/suxin/test_install hbase-1.2.6-bin.tar.gz 1.2.6 /home/suxin/test_install/hadoop suxin
  
  
  install hbase /home/suxin/test_install hbase-1.2.6-bin.tar.gz 1.2.6 /home/suxin/test_install/hadoop suxin .........
  Copying HBase 1.2.6 to all hosts...
  Set HBASE_HOME env to all hosts...
  Create Zookeeper directory for all hosts...
  Copying Hadoop config file to all hosts...
  Copying HBase config file to all hosts...
  Installing HBase to all hosts success ...  
  ```
  
  * 8) 启动HBase服务
  
  ```
  ssh -p 22 user@HBASE_MASTER
  
  ${HBASE}/bin/start-hbase.sh 
  ```
  
  ```
  starting master, logging to /home/apps/application/cluster/hbase/bin/../logs/hbase-apps-master-Hadoop.out
  Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
  Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
  172.23.0.21: starting regionserver, logging to /home/apps/application/cluster/hbase/bin/../logs/hbase-apps-regionserver-Hadoop.out
  172.23.0.23: starting regionserver, logging to /home/apps/application/cluster/hbase/bin/../logs/hbase-apps-regionserver-Hive.out
  172.23.0.22: starting regionserver, logging to /home/apps/application/cluster/hbase/bin/../logs/hbase-apps-regionserver-HBase.out
  172.23.0.23: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
  172.23.0.23: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
  172.23.0.21: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
  172.23.0.21: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
  172.23.0.22: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
  172.23.0.22: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0  
  ```
  
  * 9) 验证
  
  ```
  # sign in HBASE master and execute bash shell
  ssh -p 22 user@HBASE_MASTER
  
  ${JAVA_HOME}/bin/jps
  ```
  
  ```
  21792 Jps
  21514 HRegionServer
  21374 HMaster  
  ```
  
  ```
  # sign in HBASE regionserver and execute bash shell
  ssh -p 22 user@HBASE_REGIONSERVER
  
  ${JAVA_HOME}/bin/jps
  ```  
  
  ```
  103762 HRegionServer
  55116 Jps  
  ```
  
  * 10) 创建测试表
  
  ```
  ${HBASE}/bin/hbase shell
  
  SLF4J: Class path contains multiple SLF4J bindings.
  SLF4J: Found binding in [jar:file:/home/apps/application/cluster/hbase-1.2.6/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: Found binding in [jar:file:/home/apps/application/cluster/hadoop-2.8.3/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
  SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
  HBase Shell; enter 'help<RETURN>' for list of supported commands.
  Type "exit<RETURN>" to leave the HBase Shell
  Version 1.2.6, rUnknown, Mon May 29 02:25:32 CDT 2017  
  ```
  
  ```
  hbase(main):001:0>  create 'hbase_test',{NAME=>'cf1'}
  0 row(s) in 1.5000 seconds  
  
  => Hbase::Table - hbase_test
  hbase(main):002:0> put 'hbase_test','a','cf1:v1','1'
  0 row(s) in 0.2170 seconds  
  
  hbase(main):003:0> put 'hbase_test','b','cf1:v1','2'
  0 row(s) in 0.0160 seconds  
  
  hbase(main):004:0>  put 'hbase_test','b','cf1:v1','3'
  0 row(s) in 0.0160 seconds  
  
  hbase(main):001:0> scan 'hbase_test'
  ROW                                  COLUMN+CELL                                                                                               
    a                                   column=cf1:v1, timestamp=1529033250275, value=1                                                           
    b                                   column=cf1:v1, timestamp=1529033303016, value=3                                                           
  2 row(s) in 0.2460 seconds  
  ```
   
## 9 Hive 安装 <a name="hive_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/hive目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/hive
   ```

   * 2) 编辑文件 hive_hosts
   
   ```
   vi hive_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```
   
  * 4) 创建 Metastore（MySQL Service）,记住用户名和密码，后面的配置需要用到
  
  ```
  ssh -p 22 user@MySQL_SERVER
  ```
  
  ```
  [apps@MySQL ~]$ mysql -u root -h 127.0.0.1 -p
  Enter password: (输入密码)
  
  Welcome to the MariaDB monitor.  Commands end with ; or \g.
  Your MariaDB connection id is 12
  Server version: 10.1.33-MariaDB MariaDB Server

  Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

  Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

  MariaDB [(none)]>  create database hive;
  Query OK, 1 row affected (0.00 sec)

  MariaDB [(none)]> GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%' IDENTIFIED BY '${HIVE_PASSWORD}' WITH GRANT OPTION;
  Query OK, 0 rows affected (0.00 sec)

  MariaDB [(none)]> FLUSH PRIVILEGES;
  Query OK, 0 rows affected (0.00 sec)
  
  MariaDB [(none)]> exit;

  [apps@MySQL ~]$ exit
  ```
   
  * 5) 编辑 conf/hive-site.xml
  
  ```
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://${MYSQL_SERVER}:${MYSQL_PORT}/${HIVE_DB}?createDatabaseIfNotExist=true</value>
    <description>JDBC connect string for a JDBC metastore</description>
  </property>
  ```
  
  ```
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
  </property>  
  ```
  
  ```
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>${HIVE_DB_USER}</value>
    <description>Username to use against metastore database</description>
  </property>  
  ```
  
  ```
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${HIVE_DB_USER_PASSWORD}</value>
    <description>password to use against metastore database</description>
  </property> 
  ```
  
  ```
  <property>
    <name>hive.querylog.location</name>
    <value>${HIVE_HOME}/iotmp/${USER}</value>
    <description>Location of Hive run time structured log file</description>
  </property>  
  ```
  
  ```
  <property>
    <name>hive.server2.logging.operation.log.location</name>
    <value>${HIVE_HOME}/iotmp/${USER}/operation_logs</value>
    <description>Top level directory where operation logs are stored if logging functionality is enabled</description>
  </property>  
  ```
  
  ```
  <property>
    <name>hive.exec.local.scratchdir</name>
    <value>${HIVE_HOME}/iotmp/${USER}</value>
    <description>Local scratch space for Hive jobs</description>
  </property>  
  ```
  
  ```
  <property>
    <name>hive.downloaded.resources.dir</name>
    <value>${HIVE_HOME}/iotmp/${hive.session.id}_resources</value>
    <description>Temporary local directory for added resources in the remote file system.</description>
  </property>  
  ```
  
  ```
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>{ZOOKEEPER_IP1}:2181,{ZOOKEEPER_IP2}:2181,{ZOOKEEPER_IP3}:2181</value>
  </property>  
  ```
  
  * 6) 安装
  
  ```
  install-hive [install] [APP_HOME] [HIVE_FILE] [HIVE_VERSION] [USER]
  ```
  
  ```
  ./install-hive.sh install /home/suxin/test_install apache-hive-1.2.1-bin.tar.gz 1.2.1 suxin
  
  install hive /home/suxin/test_install apache-hive-1.2.1-bin.tar.gz 1.2.1 suxin .........
  Copying HBase 1.2.1 to all hosts...
  Set HIVE_HOME env to all hosts...
  Copying Hive config file to all hosts...
  Copying Mysql connector jar file to all hosts...
  Installing Hive to all hosts success ...  
  ```
  
  * 7) 初始化 schema
  
  ```
  ssh -p 22 user@HIVE_SERVER
  ```
  
  ```
  schematool -initSchema -dbType mysql
  
  Metastore connection URL:	 jdbc:mysql://172.23.0.31:3306/hive?createDatabaseIfNotExist=true
  Metastore Connection Driver :	 com.mysql.jdbc.Driver
  Metastore connection User:	 hive
  Starting metastore schema initialization to 1.2.0
  Initialization script hive-schema-1.2.0.mysql.sql
  Initialization script completed
  schemaTool completed  
  ```
  * 8) 验证
  
  ```
  ssh -p 22 user@HIVE_SERVER
  ```
  
  ```
  [apps@Front ~]$ hive 

  Logging initialized using configuration in jar:file:/home/apps/application/cluster/apache-hive-1.2.1-bin/lib/hive-common-1.2.1.jar!/hive-log4j.properties  

  hive> CREATE TABLE IF NOT EXISTS test_employee ( eid int, name String, salary String, destination String) COMMENT 'Employee details' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' STORED AS TEXTFILE;
  OK
  Time taken: 0.491 seconds 
  hive> select * from test_employee;
  OK
  Time taken: 0.068 seconds
  hive> drop table test_employee;
  OK
  Time taken: 0.445 seconds
  hive> create external table hbase_test(key string,value string) stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,cf1:v1") TBLPROPERTIES("hbase.table.name" = "hbase_test");
  OK
  Time taken: 2.348 seconds
  hive> select * from hbase_test;
  OK
   a	1
   b	3
  Time taken: 0.496 seconds, Fetched: 2 row(s)
  hive> exit;
  ```
  
## 10 Spark 安装 <a name="spark_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/spark目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/spark
   ```

   * 2) 编辑文件 spark_hosts
   
   ```
   vi spark_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```  
   
  * 4) 编辑文件 conf/spark-env.sh
  
  ```
  # set JAVA_HOME
  
  JAVA_HOME=${JAVA_HOME}
  ``` 
  
  * 5) 编辑文件 conf/slaves
  
  ```
  # A Spark Worker will be started on each of the machines listed below.

  172.23.0.24
  172.23.0.25
  172.23.0.26  
  ```
  
  * 6) 安装
  
  ```
  install-spark [install] [APP_HOME] [SPARK_FILE] [SPARK_VERSION] [HADOOP_VERSION] [HIVE_HOME] [USER]
  ```
  
  ```
  ./install-spark.sh install /home/suxin/test_install spark-2.2.1-bin-hadoop2.7.tgz 2.2.1 2.7 /home/suxin/test_install/hive suxin
  
  install spark /home/suxin/test_install spark-2.2.1-bin-hadoop2.7.tgz 2.2.1 2.7 /home/suxin/test_install/hive suxin .........
  Copying Spark 2.2.1 to all hosts...
  Set SPARK_HOME env to all hosts...
  Copying Spark config file to all hosts...
  Link Hive conf file to Spark for all hosts ...
  Copying libs file to all hosts ....
  Installing Spark to all hosts success ...  
  ```
  
  * 7) 启动
  
  ```
  ssh -p 22 user@SPARK_MASTER (Note: 在哪台服务器启动，那台服务器就是Master)
  ```
  
  ```
  /home/apps/application/cluster/spark/sbin/start-all.sh
  
  starting org.apache.spark.deploy.master.Master, logging to /home/apps/application/cluster/spark/logs/spark-apps-org.apache.spark.deploy.master.Master-1-Spark01.out
  172.23.0.24: starting org.apache.spark.deploy.worker.Worker, logging to /home/apps/application/cluster/spark/logs/spark-apps-org.apache.spark.deploy.worker.Worker-1-Spark01.out
  172.23.0.26: starting org.apache.spark.deploy.worker.Worker, logging to /home/apps/application/cluster/spark/logs/spark-apps-org.apache.spark.deploy.worker.Worker-1-Spark03.out
  172.23.0.25: starting org.apache.spark.deploy.worker.Worker, logging to /home/apps/application/cluster/spark/logs/spark-apps-org.apache.spark.deploy.worker.Worker-1-Spark02.out  
  ```
  
  ```
  [apps@Spark01 ~]$ jps
  19042 Worker
  12963 JournalNode
  18932 Master
  19115 Jps  
  ```
  
  * 8) 验证
  
  ```
  ssh -p 22 user@SPARK_SLAVE
  ```
  
  ```
  spark-shell master=spark://Spark01:7077
  
  Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
  Setting default log level to "WARN".
  To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
  18/06/18 15:09:52 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
  Spark context Web UI available at http://172.23.0.25:4040
  Spark context available as 'sc' (master = local[*], app id = local-1529305793804).
  Spark session available as 'spark'.
  Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.2.1
      /_/
         
  Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_171)
  Type in expressions to have them evaluated.
  Type :help for more information.

  scala> :quit
  ```
  
  ```
  spark-sql master=spark://Spark01:7077
  
  log4j:WARN No appenders could be found for logger (org.apache.hadoop.util.Shell).
  log4j:WARN Please initialize the log4j system properly.
  log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
  Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
  18/06/18 15:18:28 INFO HiveMetaStore: 0: Opening raw store with implemenation class:org.apache.hadoop.hive.metastore.ObjectStore
  18/06/18 15:18:28 INFO ObjectStore: ObjectStore, initialize called
  18/06/18 15:18:29 INFO Persistence: Property hive.metastore.integral.jdo.pushdown unknown - will be ignored
  18/06/18 15:18:29 INFO Persistence: Property datanucleus.cache.level2 unknown - will be ignored 
  ....................
  18/06/18 15:18:37 INFO SessionState: Created HDFS directory: /tmp/hive/apps/d60788e8-da64-4d80-9574-86c9d1d73815/_tmp_space.db
  18/06/18 15:18:37 INFO HiveClientImpl: Warehouse location for Hive client (version 1.2.1) is /user/hive/warehouse
  18/06/18 15:18:37 INFO StateStoreCoordinatorRef: Registered StateStoreCoordinator endpoint
  
  spark-sql> select * from hbase_test;
  18/06/18 16:13:04 INFO SparkSqlParser: Parsing command: select * from hbase_test
  18/06/18 16:13:05 INFO HiveMetaStore: 0: get_table : db=default tbl=hbase_test
  18/06/18 16:13:05 INFO audit: ugi=apps	ip=unknown-ip-addr	cmd=get_table : db=default tbl=hbase_test  
  ....................
  18/06/18 16:13:11 INFO TaskSchedulerImpl: Removed TaskSet 0.0, whose tasks have all completed, from pool 
  18/06/18 16:13:11 INFO DAGScheduler: ResultStage 0 (processCmd at CliDriver.java:376) finished in 0.926 s
  18/06/18 16:13:11 INFO DAGScheduler: Job 0 finished: processCmd at CliDriver.java:376, took 1.093052 s
   a	1
   b	3
  Time taken: 6.621 seconds, Fetched 2 row(s)
  18/06/18 16:13:11 INFO CliDriver: Time taken: 6.621 seconds, Fetched 2 row(s)
  spark-sql> exit;
  ```
  
## 11 Kafka 安装 <a name="kafka_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install-shell/kafka目录
  
   ```
   ssh -p 22 user@127.0.0.1
   cd install-shell/kafka
   ```

   * 2) 编辑文件 kafka_hosts
   
   ```
   vi kafka_hosts
   ```
     
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  
   ```
   172.23.0.21
   172.23.0.22
   172.23.0.23
   ```  
   
  * 4) 编辑文件 conf/server.properties
  
  ```
  # The port the socket server listens on
  port=9092
  ```
  
  ```
  # A comma separated list of directories under which to store log files
  log.dirs=${KAFKA_HOME}/logs  
  ```
  
  ```
  ############################# Zookeeper #############################

  # Zookeeper connection string (see zookeeper docs for details).
  # This is a comma separated host:port pairs, each corresponding to a zk
  # server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
  # You can also append an optional chroot string to the urls to specify the
  # root directory for all kafka znodes.
  zookeeper.connect=${ZOOKEEPER_IP1}:${ZOOKEEPER_PORT},${ZOOKEEPER_IP2}:${ZOOKEEPER_PORT},${ZOOKEEPER_IP3}:${ZOOKEEPER_PORT} 
  ```
  
  * 5) 安装
  
  ```
  install-kafka [install] [APP_HOME] [KAFKA_FILE] [KAFKA_VERSION] [USER]
  ```
  
  ```
  ./install-kafka.sh install /home/suxin/test_install kafka_2.11-1.1.0.tgz 2.11-1.1.0 suxin
  
  install kafka /home/suxin/test_install kafka_2.11-1.1.0.tgz 2.11-1.1.0 suxin .........
  Copying Kafka 2.11-1.1.0 to all hosts...
  Set KAFKA_HOME env to all hosts...
  Create Kafka logs directory for all hosts...
  Copying Kafka config file to all hosts...
  Installing Kafka to all hosts success ...
  ```
  
  * 6) 修改 broker.id，此步骤需要分别登录 kafka 节点操作
  
  ```
  ssh -p 22 user@kafka
  
  vi ${KAFKA_HOME}/config/server.properties
  
  # ID 必须唯一
  broker.id=${ID}
  ```
  
  * 7) 启动,分别登录kafka节点操作
  
  ```
  ${KAFKA_HOME}/bin/kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties
  ```
  
  * 8) 测试
  
  ```
  ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper 172.23.0.27:2181,172.23.0.28:2181,172.23.0.29:2181 --topic test-topic --partitions 2 --replication-factor 2
  
  # you will get below message if it is created successfully
  Created topic "test-topic".
  
  ${KAFKA_HOME}/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic
  # type your message and press enter
  First test message
  Second test message
  
  ${KAFKA_HOME}/bin/kafka-console-consumer.sh --zookeeper 172.23.0.27:2181,172.23.0.28:2181,172.23.0.29:2181 --topic test-topic --from-beginning
  # below should be output of this command
  First test message
  Second test message  
  ```
  
## 12 Flume 安装 <a name="flume_install"/>