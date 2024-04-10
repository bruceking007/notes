#!/bin/bash
set -x

now_path=$(cd `dirname $0`;pwd)  
cd $now_path
#添加zb用户
groupadd zabbix && useradd -g zabbix zabbix

#安装必要的依赖包
yum -y install gcc mysql-community-devel libxml2-devel unixODBC-devel net-snmp-devel libcurl-devel libssh2-devel OpenIPMI-devel openssl-devel openldap-devel mysql-devel libevent-devel
yum -y install pcre*

#下载zb包
cd /usr/local/src && wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.0.11/zabbix-4.0.11.tar.gz

#解压病安装
tar xvf zabbix-4.0.11.tar.gz && cd zabbix-4.0.11
./configure --prefix=/usr/local/zabbix --enable-agent
make install
cp $now_path/zabbix-4.0.11/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chkconfig --add zabbix_agentd

sed -i 's#BASEDIR\=\/usr\/local#BASEDIR\=\/usr\/local\/zabbix#' /etc/init.d/zabbix_agentd
grep BASEDIR= /etc/init.d/zabbix_agentd

#修改配置文件
cat << EOF > /usr/local/zabbix/etc/zabbix_agentd.conf
LogFile=/var/log/zabbix_agentd.log
Server=172.31.131.14
ServerActive=172.31.131.14
Hostname=db-44.78.67.34
AllowRoot=1
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf
UnsafeUserParameters=1
EOF

cat /usr/local/zabbix/etc/zabbix_agentd.conf

#防火墙设置
iptables -I INPUT -s 172.31.131.0/24 -p tcp -m tcp --dport 10050 -j ACCEPT

#重启相关服务
service itpables reload
service zabbix_agentd restart






