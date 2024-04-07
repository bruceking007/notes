#!/bin/bash
set -x
mkdir -p /data/dbbackup/{logs,tarfiles}
pw='123.com'
basedir="/data/dbbackup/$(date "+%y%m%d")"
sock=$(ps -ef|grep mysql|grep datadir|awk -F".pid" '{print $NF}'|awk  '{print $1}')
innobackupex --defaults-file=/etc/my.cnf --user=root --password=${pw} ${sock} --compress $basedir  &>> "/data/dbbackup/logs/$(date "+%y%m%d").log"
full_basedir=$(cd $basedir && ls $basedir|head -n1)
cd $basedir && tar czf /data/dbbackup/tarfiles/${full_basedir}_full.tar.gz ${full_basedir} 

