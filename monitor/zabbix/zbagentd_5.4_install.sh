#!/bin/bash
set -x

blue() {
    echo -e "\033[34m $1  \033[0m" && sleep 1
}

red() {
    echo -e "\033[31m $1  \033[0m" && sleep 1
}

now_path=$(cd `dirname $0`;pwd)  
cd $now_path

blue "安装golang"
rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO
curl -s https://mirror.go-repo.io/centos/go-repo.repo | tee /etc/yum.repos.d/go-repo.repo
yum install golang -y
go env -w GOPROXY=https://goproxy.cn
go env

blue "添加zb用户"
groupadd zabbix && useradd -g zabbix zabbix

blue "安装必要的依赖包"
yum install -y gcc mysql-devel net-snmp-devel pcre*\
curl-devel libxml2 libxml2-devel \
automake libssh2-devel libevent-devel httpd libcurl-devel.x86_64 \
kernel-devel openssl-devel popt-devel

blue "下载zb包"
cd /usr/local/src && wget https://cdn.zabbix.com/zabbix/sources/stable/5.4/zabbix-5.4.9.tar.gz

blue "解压and安装agent agent2"
tar -xzvf zabbix-5.4.9.tar.gz && cd zabbix-5.4.9
./configure --prefix=/usr/local/zabbix --enable-agent -enable-agent2
make install

blue "添加相关目录"
mkdir -pv /usr/local/zabbix/{logs,pid}
chown -R zabbix.zabbix /usr/local/zabbix/


blue "修改agent配置文件"
cat > /usr/local/zabbix/etc/zabbix_agentd.conf << EOF
#Pid 文件目录
PidFile=/usr/local/zabbix/pid/zabbix_agentd.pid
#Zabbix Agent 日志目录
LogFile=/usr/local/zabbix/logs/zabbix_agentd.log
#允许所有地址访问
#Server=0.0.0.0/0 此处只允许zabbix_server访问
Server=192.168.91.13 
#Zabbix Server 地址.
ServerActive=192.168.91.13 
Hostname=Zabbix server

AllowRoot=1
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf
UnsafeUserParameters=1
EOF
	
blue "配置 Zabbix Agent 系统服务"
cat > /usr/lib/systemd/system/zabbix-agentd.service << 'EOF'
[Unit]
Description=Zabbix Agent
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_agentd.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-agent
Type=forking
Restart=on-failure
PIDFile=/usr/local/zabbix/pid/zabbix_agentd.pid
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_agentd -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

blue "修改agent2配置文件"
cat > /usr/local/zabbix/etc/zabbix_agent2.conf << EOF
#Pid 文件目录
PidFile=/usr/local/zabbix/pid/zabbix_agentd2.pid
#Zabbix Agent 日志目录
LogFile=/usr/local/zabbix/logs/zabbix_agentd2.log
#允许所有地址访问
#Server=0.0.0.0/0 此处只允许zabbix_server访问
Server=192.168.91.13 
#Zabbix Server 地址.
ServerActive=192.168.91.13 
Hostname=Zabbix server

#AllowRoot=1
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf
UnsafeUserParameters=1
EOF
	
cat /usr/local/zabbix/etc/zabbix_agent2.conf
	
blue "配置 Zabbix Agent2 系统服务"
cat > /usr/lib/systemd/system/zabbix-agent2.service << 'EOF'
[Unit]
Description=Zabbix Agent 2
After=syslog.target
After=network.target

[Service]
Environment="CONFFILE=/usr/local/zabbix/etc/zabbix_agent2.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-agent2
Type=simple
Restart=on-failure
PIDFile=/usr/local/zabbix/pid/zabbix_agentd2.pid
KillMode=control-group
ExecStart=/usr/local/zabbix/sbin/zabbix_agent2 -c $CONFFILE
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=10s
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
	

cat /usr/lib/systemd/system/zabbix-agent2.service
	
blue "systemctl重新加载配置文件。并启动agent2"
systemctl daemon-reload
systemctl enable zabbix-agent2.service
systemctl start zabbix-agent2.service










