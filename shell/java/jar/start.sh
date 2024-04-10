#!/bin/bash
if [ `whoami` != "app" ] ; then
     echo -e "\033[32;5m------------------警告！请使用普通用户app运行此脚本!!!---------------\033[0m"
     exit 1
fi

appName=$(ls *.jar)

#开启前检查进程是否还在
count=$(ps -ef|grep $appName|grep java|wc -l)
[ $count -eq 1 ] && echo -e "\033[36m $appName 进程还存在，请检查是否已经停掉进程! \033[0m" && exit 1

#进程不在则正常启
nohup java -jar $appName &
count1=$(ps -ef|grep $appName|grep java|wc -l)
[ $count1 -eq 1 ] && echo -e "\033[36m $appName 已开启运行! \033[0m"
sleep 2 && tail -f nohup.out

