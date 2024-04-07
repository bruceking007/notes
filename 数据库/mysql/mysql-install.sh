#!/bin/bash
set -x
this_path=$(cd `dirname $0`;pwd)
cd $this_path

#创建相关目录
sleep 1 && echo -e "\033[32m 创建相关目录 \033[0m"
mkdir -p /usr/local/mysql/{data,binlog}

sleep 1 && echo -e "\033[32m 判断是否存在安装包 \033[0m"
if [ -f mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz ];then
	echo -e "\033[32m mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz已存在 \033[0m"
else
	echo -e "\033[32m mysql安装包不存在! 开始下载...... \033[0m" && wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz
fi

sleep 1 && echo -e "\033[32m 解压并mv到指定目录 \033[0m"
tar -xzvf mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz && mv mysql-5.7.23-linux-glibc2.12-x86_64/* /usr/local/mysql

#添加用户组, 创建mysql用户添加到mysql组
sleep 1 && echo -e "\033[32m 添加用户组, 创建mysql用户添加到mysql组 \033[0m"
groupadd mysql
useradd -g mysql mysql

#设置mysql文件夹权限
sleep 1 && echo -e "\033[32m 设置mysql文件夹权限 \033[0m"
chown -R mysql.mysql /usr/local/mysql/

#mysql的服务脚本放到系统服务中
sleep 1 && echo -e "\033[32m mysql的服务脚本放到系统服务中 \033[0m"
cp -a /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld

#配置文件修改
sleep 1 && echo -e "\033[32m my.cnf配置文件修改 \033[0m"
cat << EOF > /etc/my.cnf
[mysqld]  
basedir = /usr/local/mysql                                                                                  
datadir = /usr/local/mysql/data                                                                             
port = 12308
socket  = /tmp/mysql.sock  
innodb_file_per_table = ON                                                                               
character-set-server = utf8                                                                  
log-error=/usr/local/mysql/mysqld.log                                                              
pid-file=/usr/local/mysql/mysqld.pid
lower_case_table_names=1
event_scheduler = 1

server-id=1022
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

#slow_query
slow_query_log=ON
slow_query_log_file=/usr/local/mysql/mysql-slow.log
long_query_time=1

#binlog
log-bin=/usr/local/mysql/binlog/mysql-bin.log
log-slave-updates = 1  
binlog-format=row
sync-master-info = 1
sync_binlog = 1
expire_logs_days = 10
max_binlog_size = 100M 
log_bin_trust_function_creators=1

#GTID 
gtid-mode=on
enforce-gtid-consistency=on
master-info-repository=TABLE
relay-log-info-repository=TABLE
slave-parallel-workers=0
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
auto-increment-increment = 2
auto-increment-offset = 1
skip_slave_start=1
report-host=192.168.10.193
report-port=12308
EOF

ip=`ip a|grep inet|grep global|awk '{print $2}'|awk -F/ '{print $1}'`
sed -i 's#report-host=192.168.10.193#report-host='"$ip"'#g' /etc/my.cnf

#查看mysql文件权限
ls -l /usr/local/mysql/

#初始化数据库
sleep 1 && echo -e "\033[32m 初始化数据库 \033[0m"
cd /usr/local/mysql/bin/ && ./mysqld --initialize --user=mysql --basedir=/usr/local/mysql/--datadir=/usr/local/mysql/data/

#设置启动
\cp -f /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql && chmod +x /etc/init.d/mysql
chkconfig --add mysql && chkconfig --list mysql

#启动
sleep 1 && echo -e "\033[32m 启动 \033[0m"
service mysql start
ps -ef|grep mysql

#临时密码
sleep 1
DBPWD=$(grep 'temporary password' /usr/local/mysql/mysqld.log|awk '{print $NF}')
echo -e "\033[32m mysql临时密码为:$DBPWD \033[0m"

#mysql路径指定
ln -sfv /usr/local/mysql/bin/mysql /usr/bin/mysql

