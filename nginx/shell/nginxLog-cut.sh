#!/bin/bash
mainDir='/data/nginx/logs'
log_name="access.log"
#arrJava=(`find $mainDir -type d -name "*"|grep -vw '/data/nginx/logs/'`)
arrJava=(`find $mainDir -type d -name "*"`)
#arrJava=(adminweb)
for value in "${arrJava[@]}"
do
    #echo $value
    if [ -f ${value}/${log_name} ];then
         #echo ${value}/${log_name}
         mv ${value}/${log_name} ${value}/access-`date -d last-day +%F`.log
    fi
done

#重载nginx 服务
/usr/local/nginx/sbin/nginx -s reload
#查找nginx 日志目录下30天前的日志并删除
find  ${mainDir} -name '*.log' -mtime +30 -exec rm -rf {} \;
