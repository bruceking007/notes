#!/bin/bash
FILENAME="/var/log/usermonitor.log"
PATHNAME="/etc/profile"
FINDNAME="HISTORY_FILE"
if [[ ! -f ${FILENAME} ]]
then
    #创建行为审计日志文件
    touch ${FILENAME}     
    #将日志文件的所有者改为权限低的用户NOBODY
    chown nobody:nobody ${FILENAME}         
    #赋予所有用户对日志文件写的权限
    chmod 002 ${FILENAME}
    #使所有用户对日志文件只有追加权限
    chattr +a ${FILENAME}
fi 

if [[ `cat ${PATHNAME} | grep ${FINDNAME} | wc -l` < 1 ]]; then
cat >> ${PATHNAME} <<"EOF"
export HISTORY_FILE=/var/log/usermonitor.log
export PROMPT_COMMAND='{ date "+%y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}")  #### $(id|awk "{print \$1}") #### $(history 1 | { read x cmd; echo "$cmd"; })"; } >> ${HISTORY_FILE}'
EOF
else
      exit 0 
fi
