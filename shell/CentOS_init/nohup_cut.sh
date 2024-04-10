#!/bin/bash
#date: 2022-01-08
#desc: For cut nohup.out

this_path=$(cd dirname $0;pwd)  
cd $this_path  
current_date=date -d "-1 day" "+%Y%m%d"  
arrJava=$(ls /home/java)

for value in ${arrJava[@]}
do
  logDir="/home/java/$value/appcode"
  splitDir="/home/java/$value/logs"
    sfile="$logDir/nohup.out"
  if [ -f $sfile ];then
    #echo $sfile
    mkdir -pv $splitDir 
    split -b 1024m -d -a 4 $sfile  ${splitDir}/nohup_${current_date}_
	chown -R app.app $splitDir
    cat /dev/null > $sfile
    find ${splitDir} -type f -name "*" -mtime +14 |xargs rm -f 
  fi
done