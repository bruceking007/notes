#!/bin/bash
#date:2021-10-22
#des:for ins redis-cluster
set -e
REDDIR="/usr/local/redis-cluster"
CURRENTDIR=$(cd $(dirname $0); pwd)
REDDIRCMD='\/usr\/local\/redis-cluster'

ist_redis () {
#echo -ne "\033[33m 请输入要部署redis的IP: \033[0m" && read REDIP
#if [ ! -n "$REDIP" ];then 
#    echo "redis的IP 没有设置!" && exit 0
#fi
echo -ne "\033[33m 请输入要部署redis的端口: \033[0m" && read REDPORT
if [ ! -n "$REDPORT" ];then
    echo "redis的端口 没有设置!" && exit 0
fi

echo -e "\033[36m 判断是否存在安装包 \033[0m" && sleep 3
if [ -f redis*.gz ];then
    gzfile=$(ls redis*.gz)
    echo -e "\033[36m ${gzfile}已存在 \033[0m"
else
    echo -e "\033[36m redis安装包不存在! 开始下载...... \033[0m" && wget http://download.redis.io/releases/redis-4.0.2.tar.gz
fi

#解压、编译、安装redis-4.0.2
echo -e "\033[36m 解压、编译、安装redis \033[0m" && sleep 3
tar -zxvf redis-4.0.2.tar.gz -C /usr/local/ && cd /usr/local/redis-4.0.2 && make && make install
#创建文件夹
echo -e "\033[36m 创建文件夹 \033[0m" && sleep 3
mkdir -pv ${REDDIR}/{data,pid,logs,bin,config}
mkdir -pv ${REDDIR}/data/${REDPORT}

REDIS_CONF="${REDDIR}/config/redis-${REDPORT}.conf"
#cd ${REDDIR} && mv redis.conf redis-${REDPORT}.conf
cp -a /usr/local/redis-4.0.2/redis.conf ${REDIS_CONF}
#cd /usr/local/redis-4.0.2/src && cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-check-dump redis-cli redis-server redis-trib.rb ${REDDIR}/bin/
cd /usr/local/redis-4.0.2/src && cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-cli redis-server redis-trib.rb ${REDDIR}/bin/
#ln -sfv /usr/local/bin/redis-* ${REDDIR}/bin/
echo "export PATH=$PATH:${REDDIR}/bin" >> /etc/profile && source /etc/profile
ls -l ${REDDIR}/bin/

#编辑配置文件
echo -e "\033[36m 编辑配置文件 \033[0m" && sleep 3
cat > ${REDIS_CONF} << EOF
port ${REDPORT}
daemonize yes
bind 0.0.0.0
cluster-enabled yes
cluster-config-file redis-${REDPORT}.conf
dir ${REDDIR}/data/${REDPORT}/
pidfile ${REDDIR}/pid/redis-${REDPORT}.pid
logfile ${REDDIR}/logs/redis-${REDPORT}.log
cluster-node-timeout 15000
appendonly yes
EOF

#添加启动脚本
REDIS_SHELL

#启动
echo -e "\033[36m 启动redis \033[0m" && sleep 3
service redis-${REDPORT} start
netstat -anptu | grep ${REDPORT}
}

cp_redis() {
#echo -ne "\033[33m 请输入要部署redis的IP: \033[0m" && read REDIP 
#if [ ! -n "$REDIP" ];then 
#    echo "redis的IP 没有设置!" && exit 0
#fi
echo -ne "\033[33m 请输入要部署redis的端口: \033[0m" && read REDPORT
if [ ! -n "$REDPORT" ];then
    echo "redis的端口 没有设置!" && exit 0
fi

mkdir -pv ${REDDIR}/data/${REDPORT}
REDIS_CONF="${REDDIR}/config/redis-${REDPORT}.conf"
cp -a /usr/local/redis-4.0.2/redis.conf ${REDIS_CONF}
#编辑配置文件
echo -e "\033[36m 编辑配置文件 \033[0m" && sleep 3
cat > ${REDIS_CONF} << EOF
port ${REDPORT}
daemonize yes
bind 0.0.0.0
cluster-enabled yes
cluster-config-file redis-${REDPORT}.conf
dir ${REDDIR}/data/${REDPORT}/
pidfile ${REDDIR}/pid/redis-${REDPORT}.pid
logfile ${REDDIR}/logs/redis-${REDPORT}.log
cluster-node-timeout 15000
appendonly yes
EOF

#添加启动脚本
REDIS_SHELL

#启动
echo -e "\033[36m 启动redis \033[0m" && sleep 3
service redis-${REDPORT} start
netstat -anptu | grep ${REDPORT}
}

ist_ruby () {
#安装集群所需软件
echo -e "\033[36m 安装集群所需软件 \033[0m" && sleep 3
yum remove ruby
cd ${CURRENTDIR} && tar zxf ruby-3.0.2.tar.gz && cd ruby-3.0.2
./configure --prefix=/usr/local/ruby
make && make install

/usr/local/ruby/bin/ruby -v

#设置环境变量
echo -e "\033[36m 设置环境变量 \033[0m" && sleep 3
echo 'export PATH=$PATH:/usr/local/ruby/bin:' >>  /etc/profile && source  /etc/profile

#镜像加速
echo -e "\033[36m 镜像加速 \033[0m" && sleep 3
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
gem sources -l

gem install redis
}

ist_ruby_compile () {
#安装集群所需软件
echo -e "\033[36m 安装集群所需软件 \033[0m" && sleep 3
yum remove ruby
cd ${CURRENTDIR} && tar xf ruby_compile.tar.gz -C  /usr/local/
/usr/local/ruby/bin/ruby -v

#设置环境变量
echo -e "\033[36m 设置环境变量 \033[0m" && sleep 3
echo 'export PATH=$PATH:/usr/local/ruby/bin:' >>  /etc/profile && source  /etc/profile

#镜像加速
echo -e "\033[36m 镜像加速 \033[0m" && sleep 3
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
gem sources -l

gem install redis
}

REDIS_SHELL () {
echo -e "\033[36m 添加启动脚本 \033[0m" && sleep 3
cat >  /etc/init.d/redis-${REDPORT} << 'EOF'
#!/bin/sh
## Simple Redis init.d script conceived to work on Linux systems
## as it does use of the /proc filesystem.
PATH=REDDIR/bin:/sbin:/usr/bin:/bin
REDISPORT=REDPORT
EXEC=REDDIR/bin/redis-server
CLIEXEC=REDDIR/bin/redis-cli
PIDFILE=REDDIR/pid/redis-REDPORT.pid
CONF=REDDIR/config/redis-REDPORT.conf

start_redis () {
    if [ -f $PIDFILE ]
    then
        echo "$PIDFILE exists, process is already running or crashed"
    else
        echo "Starting Redis server..."
        $EXEC $CONF
    fi
}

stop_redis () {
    if [ ! -f $PIDFILE ]
    then
        echo "$PIDFILE does not exist, process is not running"
    else
        PID=$(cat $PIDFILE)
        echo "Stopping ..."
        $CLIEXEC -p $REDISPORT shutdown
        while [ -x /proc/${PID} ]
        do
            echo "Waiting for Redis to shutdown ..."
            sleep 1
        done
        echo "Redis stopped"
    fi
}

redis_status () {
    if [  -f $PIDFILE ];then
        netstat -anptu | grep REDPORT
    else
        echo "$PIDFILE does not exist, process is not running"
    fi

}

case "$1" in
    start)
        start_redis
        ;;
    stop)
        stop_redis
        ;;
    restart)
        stop_redis
        start_redis
        ;;
    status)
        redis_status
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
EOF

sed -i "s/REDPORT/${REDPORT}/g" /etc/init.d/redis-${REDPORT}
sed -i "s/REDDIR/${REDDIRCMD}/g" /etc/init.d/redis-${REDPORT}

chmod a+x /etc/init.d/redis-${REDPORT}
}

cat << EOF
+-----【redis部署】------+
|1、 安装redis           |
|2、 安装ruby            |
|3、 拷贝已编译ruby(快捷)|
|4、 本机再起一个服务    |
+=======================-+
|[Q|q|quit] to quit      |
+------------------------+
EOF

echo -ne "\033[32m -->【请选择你要执行的选项编号!(1|2|3)】: \033[0m"
read choice

case $choice in
    1)
      ist_redis
      ;;
    2)
      ist_ruby
      ;;
    3)
	  ist_ruby_compile
      ;;
    4)
      cp_redis
      ;;
    Q|q|quit)
      exit
      ;;
    *)
      echo "程序异常退出,Please: select one number(1|2|3)"
      exit
      ;;
esac

