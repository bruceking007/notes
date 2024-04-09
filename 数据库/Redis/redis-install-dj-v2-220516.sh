#!/bin/bash
#date:2021-10-22
#des:for ins redis-cluster
set -e
REDDIR="/usr/local/redis"
CURRENTDIR=$(cd $(dirname $0); pwd)
REDDIRCMD='\/usr\/local\/redis'

ist_redis () {
echo -ne "\033[33m 请输入要部署redis的IP: \033[0m" && read REDIP 
if [ ! -n "$REDIP" ];then 
    echo "redis的IP 没有设置!" && exit 0
fi
echo -ne "\033[33m 请输入要部署redis的端口: \033[0m" && read REDPORT
if [ ! -n "$REDPORT" ];then
    echo "redis的端口 没有设置!" && exit 0
fi


echo -e "\033[36m 判断是否存在安装包 \033[0m" && sleep 3
if [ -f redis-4.0.2.tar.gz ];then
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
cp -a /usr/local/redis-4.0.2/redis.conf $REDIS_CONF
#cd /usr/local/redis-4.0.2/src && cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-check-dump redis-cli redis-server redis-trib.rb ${REDDIR}/bin/
cd /usr/local/redis-4.0.2/src && cp mkreleasehdr.sh redis-benchmark redis-check-aof redis-cli redis-server redis-trib.rb ${REDDIR}/bin/
#ln -sfv /usr/local/bin/redis-* ${REDDIR}/bin/
echo "export PATH=$PATH:${REDDIR}/bin" >> /etc/profile && source /etc/profile
ls -l ${REDDIR}/bin/

#编辑配置文件
echo -e "\033[36m 编辑配置文件 \033[0m" && sleep 3
sed -i "s/^bind.*/bind 127.0.0.1 $REDIP/" $REDIS_CONF
sed -i "s/^port.*/port ${REDPORT}/" $REDIS_CONF
sed -i 's/^daemonize.*/daemonize yes/' $REDIS_CONF
sed -i "s/^dir.*/dir \/usr\/local\/redis\/data\/${REDPORT}/" $REDIS_CONF
sed -i "s/^pidfile.*/pidfile \/usr\/local\/redis\/pid\/redis-${REDPORT}.pid/" $REDIS_CONF
sed -i "s/^logfile.*/logfile \/usr\/local\/redis\/logs\/redis-${REDPORT}.log/" $REDIS_CONF

#添加启动脚本
REDIS_SHELL

#启动
echo -e "\033[36m 启动redis \033[0m" && sleep 3
service redis-${REDPORT} start
netstat -anptu | grep ${REDPORT}
}

cp_redis() {
echo -ne "\033[33m 请输入要部署redis的IP: \033[0m" && read REDIP 
if [ ! -n "$REDIP" ];then 
    echo "redis的IP 没有设置!" && exit 0
fi
echo -ne "\033[33m 请输入要部署redis的端口: \033[0m" && read REDPORT
if [ ! -n "$REDPORT" ];then
    echo "redis的端口 没有设置!" && exit 0
fi

mkdir -pv ${REDDIR}/data/${REDPORT}

REDIS_CONF="${REDDIR}/config/redis-${REDPORT}.conf"
cp -a /usr/local/redis-4.0.2/redis.conf $REDIS_CONF

#编辑配置文件
echo -e "\033[36m 编辑配置文件 \033[0m" && sleep 3
sed -i "s/^bind.*/bind 127.0.0.1 $REDIP/" $REDIS_CONF
sed -i "s/^port.*/port ${REDPORT}/" $REDIS_CONF
sed -i 's/^daemonize.*/daemonize yes/' $REDIS_CONF
sed -i "s/^dir.*/dir \/usr\/local\/redis\/data\/${REDPORT}/" $REDIS_CONF
sed -i "s/^pidfile.*/pidfile \/usr\/local\/redis\/pid\/redis-${REDPORT}.pid/" $REDIS_CONF
sed -i "s/^logfile.*/logfile \/usr\/local\/redis\/logs\/redis-${REDPORT}.log/" $REDIS_CONF


#添加启动脚本
REDIS_SHELL

#启动
echo -e "\033[36m 启动redis \033[0m" && sleep 3
service redis-${REDPORT} start
netstat -anptu | grep ${REDPORT}
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
|2、 本机再起一个服务    |
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
