#!/bin/bash 
#backup MongoDB 
#date 2021-12-26
 
#mongodump命令路径 
DUMP=/usr/bin/mongodump

#备份目录 
BAK_DIR=/data/backup/mongoDB
LOG_DIR=/data/backup/mongoDB/logs
test ! -d $BAK_DIR  && mkdir $BAK_DIR
test ! -d $LOG_DIR  && mkdir $LOG_DIR

#获取当前系统时间 
DATE=`date +%Y_%m_%d` 

#数据库账号 
DB_USER=root

#数据库密码 
DB_PASS=kkxx@nb.com

#DAYS=15代表删除15天前的备份，即只保留近15天的备份 
DAYS=15 
 
#备份全部数据库 
$DUMP -h localhost:27129 -u $DB_USER -p $DB_PASS --authenticationDatabase "admin" --gzip --archive=${BAK_DIR}/mongodb_bak_${DATE}.gz > ${LOG_DIR}/mongodb_bak_${DATE}.log 2>&1
#删除15天前的备份文件 
find $BAK_DIR/ -mtime +$DAYS | xargs rm -f 
exit 
