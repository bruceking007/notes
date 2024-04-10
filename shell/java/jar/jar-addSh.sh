#!/bin/bash
#date: 2022-01-09
#desc: For add sh for jar

blue() {
    echo -e "\033[34m $1  \033[0m" && sleep 1
}

this_path=$(cd `dirname $0`;pwd)  
cd $this_path  
current_date=`date -d "-1 day" "+%Y%m%d"`  
arrJava=$(ls /home/java)

for value in ${arrJava[@]}
do
	jarDir="/home/java/$value/appcode"
    startfile="$jarDir/start.sh"
    stopfile="$jarDir/stop.sh"
    
    if [ -f $jarDir/*.jar ];then
         \cp -av start.sh stop.sh $jarDir/
         chown app.app $jarDir/*.sh && chmod +x $jarDir/*.sh
         ls -l $jarDir/*.sh
    blue "=================$jarDir 已添加================"
    fi
done
