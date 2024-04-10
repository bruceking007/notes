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
    
    if [ -f $jarDir/*.jar ];then
         \cp -v up-down-jar.sh $jarDir/
         chown app.app $jarDir/*.sh && chmod +x $jarDir/*.sh
         ls -l $jarDir/*.sh
        blue "=================$jarDir 已添加================"
    elif [ -d $jarDir/WEB-INF ];then
        \cp -v up-down-java.sh /home/java/$value/bin/
        chown app.app /home/java/$value/bin/up-down-java.sh && chmod +x /home/java/$value/bin/up-down-java.sh
        ls -l /home/java/$value/bin/up-down-java.sh
        blue "=================$javaDir 已添加================"
    fi
done
