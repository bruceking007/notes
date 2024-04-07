#!/bin/bash
#适用于kafka zookeeper集成部署
zkPort=2181
kaPort=9092
kaFile='/usr/local/kafka/config/server.properties'
zkFile='/usr/local/kafka/config/zookeeper.properties'
logsDir='/data/logs'
blue() {
	echo -e "\033[34m $1  \033[0m" && sleep 1
}

red() {
    echo -e "\033[31m $1  \033[0m" && sleep 1
}


function start_zk() {
    zknum=$(ss -tunlp|grep -w ${zkPort}|wc -l)
    kanum=$(ss -tunlp|grep -w ${kaPort}|wc -l)
    if [ $zknum -eq 0 ] && [ $kanum -eq 0 ];then
        #nohup zookeeper-server-start.sh ${zkFile} > ${logsDir}/zk-`date +%y%m%d-%H%M`.log 2>&1 &
		zookeeper-server-start.sh -daemon ${zkFile}
        #tail -f  zk-`date +%y%m%d-%H%M`.log
    fi

    while true; do
      zknum=$(ss -tunlp|grep -w ${zkPort}|wc -l)
      if [ "$zknum" = "0" ]; then
        blue "The zookeeper  process is starting, it may take some time, please wait patiently..."
        sleep 1
      else
        red "zookeeper start successfully!"
        break
      fi
    done

}

function start_ka() {
    zknum=$(ss -tunlp|grep -w ${zkPort}|wc -l)
    if [ "$zknum" = 1 ];then 
        #nohup kafka-server-start.sh ${kaFile} > ${logsDir}/kafka-`date +%y%m%d-%H%M`.log 2>&1 &
		kafka-server-start.sh -daemon ${kaFile}
        #tail -f  kafka-`date +%y%m%d-%H%M`.log
    else
        #echo "请先启动zookeeper！"
        red "请先启动zookeeper"
        exit 0
    fi

    while true; do
      kanum=$(ss -tunlp|grep -w ${kaPort}|wc -l)
      if [ "$kanum" = "0" ]; then
        blue "The kafka  process is starting, it may take some time,please wait patiently..."
        sleep 1
      else
        red "kafka start successfully!"
        break
      fi
    done
}

function stop_ka() {
    kanum=$(ss -tunlp|grep -w ${kaPort}|wc -l)
    if [ "$kanum" = "1" ]; then
        kafka-server-stop.sh -daemon ${kaFile}
    fi
    
    while true; do
      kanum=$(ss -tunlp|grep -w ${kaPort}|wc -l)
      if [ "$kanum" = "1" ]; then
        #echo "The kafka  process is exiting, it may take some time, forcing the exit may cause damage to the database, please wait patiently..."
        blue "The kafka  process is exiting, it may take some time, forcing the exit may cause damage to the database, please wait patiently..."
        sleep 1
      else
        #echo "kafka stop successfully!"
        red "kafka stop successfully!"
        break
      fi
    done
}

function stop_zk() {
    kanum=$(ss -tunlp|grep -w ${kaPort}|wc -l)
    if [ "$kanum" = "1" ]; then
        #echo "请先停止kafka!"
        red "请先停止kafka!"
        exit 0
    fi

    zknum=$(ss -tunlp|grep -w ${zkPort}|wc -l)
    if [ "$zknum" = "1" ]; then
       zookeeper-server-stop.sh -daemon ${zkFile}
    fi

    while true; do
      kanum=$(ss -tunlp|grep -w ${zkPort}|wc -l)
      if [ "$kanum" = "1" ]; then
        #echo "The zookeeper  process is exiting, it may take some time, forcing the exit may cause damage to the database, please wait patiently..."
        blue "The zookeeper  process is exiting, it may take some time, forcing the exit may cause damage to the database, please wait patiently..."
        sleep 1
      else
        #echo "zookeeper stop successfully!"
        red "zookeeper stop successfully!"
        break
      fi
    done
}

#start_zk
#start_ka
#stop_ka
#stop_zk

cat << EOF
+-------【kafka启停】---------+
|1、 启动zookeeper            |
|2、 启动kafka                |
|3、 停止kafka                |
|4、 停止zookeeper            |
|5、 顺序启动zookeeper、kafka |
|6、 顺序停止kafka、zookeeper||
+============================-+
|[Q|q|quit] to quit           |
+-----------------------------+
EOF

echo -ne "\033[32m -->【请选择你要执行的选项编号!(1|2|3)】: \033[0m"
read choice

case $choice in
    1)
      start_zk
      #tail -f  zk-`date +%y%m%d-%H%M`.log
      ;;
    2)
      start_ka
      ;;
    3)
      stop_ka
      ;;
    4)
      stop_zk
      ;;
    5)
      start_zk
      start_ka
      ;;
    6)
      stop_ka
      stop_zk
      ;;      
    Q|q|quit)
      exit
      ;;
    *)
      echo "程序异常退出,Please: select one number(1|2|3)"
      exit
      ;;
esac
