#!/bin/bash
ins_zbc() {
set -x
ip=$(curl ifconfig.me)
now_path=$(cd `dirname $0`;pwd)  
cd $now_path
#添加zb用户
groupadd zabbix && useradd -g zabbix zabbix

#安装必要的依赖包
yum -y install gcc mysql-community-devel libxml2-devel unixODBC-devel net-snmp-devel libcurl-devel libssh2-devel OpenIPMI-devel openssl-devel openldap-devel mysql-devel libevent-devel
yum -y install pcre*

#安装pcre
wget https://netix.dl.sourceforge.net/project/pcre/pcre/8.40/pcre-8.40.tar.gz
tar -zxvf pcre-8.40.tar.gz && cd pcre-8.40 && ./configure -prefix=/usr/local/pcre
make && make install
ln -sfv /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1

#下载zb包
cd /usr/local/src && wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.0.11/zabbix-4.0.11.tar.gz

#解压安装
tar xvf zabbix-4.0.11.tar.gz && cd zabbix-4.0.11
./configure --prefix=/usr/local/zabbix -with-libpcre=/usr/local/pcre --enable-agent
make install
cp $now_path/zabbix-4.0.11/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chkconfig --add zabbix_agentd

sed -i 's#BASEDIR\=\/usr\/local#BASEDIR\=\/usr\/local\/zabbix#' /etc/init.d/zabbix_agentd
grep BASEDIR= /etc/init.d/zabbix_agentd

#修改配置文件
cat << EOF > /usr/local/zabbix/etc/zabbix_agentd.conf
LogFile=/var/log/zabbix_agentd.log
Server=172.16.0.175
ServerActive=172.16.0.175
Hostname=zb
AllowRoot=1
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf
UnsafeUserParameters=1
EOF

sed -i 's/Hostname=zb/Hostname='"${project}"'-'"${ip}"'/g' /usr/local/zabbix/etc/zabbix_agentd.conf
cat /usr/local/zabbix/etc/zabbix_agentd.conf && sleep 5

#防火墙设置
#iptables -I INPUT -s 172.31.131.0/24 -p tcp -m tcp --dport 10050 -j ACCEPT

#重启相关服务
#service itpables reload
service zabbix_agentd restart
}

cat << EOF
+---【安装zabbix_client】----+
|1、 添加tomcat              |
|2、 添加nginx               |
|3、 添加test                |
|4、 添加windows             |
+============================+
|[Q|q|quit] to quit |
+-------------------+
EOF

echo -ne "\033[32m -->【请选择你要执行的选项编号!(1|2|3|4|5)】: \033[0m"
read choice

case $choice in
    1)
      project=tomcat
      ins_zbc
      ;;
    2)
      project=nginx
      ins_zbc
      ;;
    3)
      project=test
      ins_zbc
      ;;
    4)
      project=windows
      ins_zbc
      ;;
    Q|q|quit)
      exit
      ;;
    *)
      echo "程序异常退出,Please: select one number(1|2|3)"
      exit
      ;;
esac

