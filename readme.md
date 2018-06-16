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
## [5 JDK 安装](#jdk_install)
## [6 Zookeeper 安装](#zookeeper_install)


-------------------
## 1. 关于文档 <a name="about_doc"/>
   本文档作为售前运维，技术运维，技术研发安装部署集群参考手册，提供了整个集群安装部署需要注意的事项和部署方法.

## 2. 背景知识 <a name="background"/>
   为了让项目成员从繁琐的集群配置和安装命令中解脱出来，降低集群安装运维成本，整理出这份文档,用以标准化流程.

## 3. 准备工作 <a name="prepare_work"/>
   选择集群服务器中某台服务器作为安装跳板机,以下简称跳板机，所有的安装文件都将会存放在此台服务器中.
### 3.1 安装 expect <a name="install_expect"/>
   * 1) 超级权限用户登录跳板机
   * 2) sudo yum install -y expect

### 3.2 安装 pdsh <a name="install_pdsh"/>
   * 1) 超级权限用户登录跳板机
   * 2) sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   * 3) sudo yum install -y pdsh

### 3.3 超级权限用户免密登录 <a name="root_create_ssh_key"/>
   * 1) 超级权限用户登录跳板机,进入安装目录中的initial目录
   * 2) expect initial.exp distSSHKey IP_LIST(127.0.0.1,127.0.0.2) apps(超级权限用户) apps_password(超级权限用户密码)

### 3.4 集群安装 expect <a name="install_all_expect"/>
   * 1) 超级权限用户登录跳板机,进入install目录
   * 2) vi all_hosts
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   * 4) pdsh -w ^all_host sudo yum install -y expect
   
### 3.5 集群安装 pdsh <a name="install_all_pdsh"/>
   * 1) 超级权限用户登录跳板机,进入install目录
   * 2) vi all_hosts
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   * 4) sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   * 5) sudo yum install -y pdsh

### 3.6 配置Hosts <a name="hosts_config"/>
   * 1) 超级权限用户登录服务器，进入install目录
   * 2) vi all_hosts
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   * 4) cp /etc/hosts ./
   * 5) 编辑 hosts 文件，将集群服务器对应的 ip地址和hostname 都加进该文件,并保存退出
   * 6) pdcp -w ^all_hosts hosts /etc/hosts

### 3.7 创建用户（可选）<a name="create_user"/>
   * 1) 超级权限用户登录跳板机,进入安装目录中的initial目录
   * 2) expect initial.exp userCreate IP_LIST(127.0.0.1,127.0.0.2) root(root用户名) root_password（root密码） apps（需要创建的用户名） apps_password（新密码） apps_group（用户组）

### 3.8 创建免密登录 <a name="create_ssh_key"/>
   * 1) 上传安装文件到3.7步骤创建的用户目录下
   * 2) 用3.7步骤创建的用户登录跳板机,进入安装目录中的initial目录
   * 3) expect initial.exp distSSHKey IP_LIST(127.0.0.1,127.0.0.2) apps(用户名) apps_password(用户密码)
   * 4) expect initial.exp initKnownKey HOSTNAME_LIST(HadoopRM,HadoopNN) apps(用户名) apps_password(用户密码)
   * 5) 重复1 - 4步骤，直至完成所有服务器

### 3.9 创建挂载数据盘目录 <a name="create_mount_dir"/>
   * 1) 用3.7步骤创建的用户登录跳板机,进入install目录
   * 2) vi all_hosts
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出   
   * 4) pdsh -w ^all_hosts mkdir -p /home/${3.7步骤创建的用户名}/application

### 3.10 挂载数据盘（可选）<a name="mount_disk"/>
   * 1) 超级权限用户登录服务器
   * 2) sudo lsblk
   * 3) sudo mkfs.ext4 ${步骤2看到的数据盘标识，例：/dev/sdb,/dev/sdc} 
   * 4) 按步骤选择Y即可
   * 5) 重复1 - 4步骤，直至完成所有服务器
   * 6) 超级权限用户登录跳板机,进入install目录
   * 7) vi all_hosts
   * 8) 将所有服务器写入文件，一行一个服务器，并保存退出 
   * 9) pdsh -w ^all_hosts sudo mount ${步骤2看到的数据盘标识，例：/dev/sdb,/dev/sdc}  /home/${3.7步骤创建的用户名}/application(3.9步骤创建的挂载目录)
   * 10) pdsh -w ^all_hosts sudo chown ${3.7步骤创建的用户}:${3.7步骤创建的用户组} /home/${3.7步骤创建的用户名}/application(3.9步骤创建的挂载目录)
   * 11）sudo blkid (需要每台服务器独立操作的步骤)
   * 12) sudo vim /etc/fstab
   * 13) 将 "UUID=${步骤11看到的数据盘（步骤9挂载的/dev/sdb或者/dev/sdc）的UUID}  /home/${3.7步骤创建的用户名}/application(3.9步骤创建的挂载目录) ext4 defaults 0 0" 加到末行
   * 14) 重复11 - 13步骤，直至完成所有服务器

### 3.11 防火墙设置（可选）<a name="set_firewalld"/>
   * 1) 超级权限用户登录服务器
   * 2) vi all_hosts
   * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
   * 4) pdsh -w ^all_hosts sudo systemctl stop firewalld.service
   * 5) pdsh -w ^hadoop_cluster sudo systemctl disable firewalld.service
   * 6) 如果不能关闭防火墙，可以使用 pdsh -w ^hadoop_cluster sudo firewall-cmd --zone=public --add-port=${PORT}/tcp --permanent 命令添加放行端口号
   * 7) 如果是步骤6 执行如下命令使防火墙端口放行命令生效 pdsh -w ^hadoop_cluster sudo firewall-cmd --reload
   
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
   *  Step 1. Add MariaDB Yum Repository
   **   1) sudo vi /etc/yum.repos.d/MariaDB.repo
   **   2) 添加如下内容进文件,并保存退出
   > {
         [mariadb]
         name = MariaDB
         baseurl = http://yum.mariadb.org/10.1/centos7-amd64
         gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
         gpgcheck=1   
     }
     
   *  Step 2. Install MariaDB in CentOS 7
   ** 1) sudo yum groupinstall mariadb*
   ** 2) sudo systemctl start mariadb
   ** 3) sudo systemctl enable mariadb
   ** 4) sudo systemctl status mariadb
   
   
   * Step 3. Secure MariaDB in CentOS 7
   ** mysql_secure_installation 完成相应的步骤即可.
   
## 5 JDK 安装 <a name="jdk_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install/jdk目录
  * 2) vi jdk_hosts
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  * 4) install-jdk [install] [APP_HOME] [JDK_FILE] [JAVA_VERSION] [USER]
  * 5) 可选： 用3.7步骤创建的用户登录跳板机, 输入jps命令，如果能运行则安装成功.
  
## 6 Zookeeper 安装 <a name="zookeeper_install"/>
  * 1) 用3.7步骤创建的用户登录跳板机,进入install/zookeeper目录
  * 2) vi zookeeper_hosts
  * 3) 将所有服务器写入文件，一行一个服务器，并保存退出
  * 4) install-zookeeper [install] [APP_HOME] [ZookeeperFile] [ZOOKEEPER_VERSION] [MYID_LIST:HOSTNAME:ID,HOSTNAME:ID] [USER]
  * 5) 可选：增加服务自启动 install-zookeeper [checkconfigon] [ZOOKEEPER_HOME]
  * 6) 用3.7步骤创建的用户登录Zookeeper服务器
  * 7) ${ZOOKEEPER_HOME}/bin/zkServer.sh start
  * 8) ${JAVA_HOME}/bin/jps 看到 QuorumPeerMain 进程表示成功
  * 9) 重复6 - 8步骤，直至完成zookeeper集群所有服务器.