#!/bin/bash
if [ `whoami` != "app" ] ; then
     echo -e "\033[32;5m------------------警告！请使用普通用户app运行此脚本!!!---------------\033[0m"
     exit 1
fi

appName=$(ls *.jar)
ps -ef|grep $appName|grep java && sleep 1
ps -ef|grep $appName|grep java|awk {'print $2'}|xargs kill -9

count=$(ps -ef|grep $appName|grep java|wc -l)
[ $count -eq 0 ] && echo -e "\033[36m $appName 已停! \033[0m"
