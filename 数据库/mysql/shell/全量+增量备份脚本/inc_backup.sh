#!/bin/bash
set -x
mkdir -p /data/backup/logs
basedir="/data/backup/$(date "+%y%m%d")" 
add_basedir="$basedir/`ls $basedir|tail -n1`"
innobackupex --defaults-file=/etc/my.cnf --user=root --password=qwe123 --socket=/data/mysql/run/mysql.sock --incremental-basedir="$add_basedir" --incremental $basedir  &>> "/data/backup/logs/$(date "+%y%m%d%H%M").log" 
inc_basedir=$(cd $basedir && ls $basedir|tail -n1)
cd $basedir && tar czf /data/backup/tarfiles/${inc_basedir}_inc.tar.gz ${inc_basedir}


