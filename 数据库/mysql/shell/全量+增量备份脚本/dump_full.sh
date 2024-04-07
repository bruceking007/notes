#!/bin/bash
#注释：mysql DB的全库备份脚本
#url: https://www.cnblogs.com/kevingrace/p/9403353.html
DB_USER='root'
DATE=`date -d"today" +%Y%m%d`
TIME=`date "+%Y-%m-%d %H:%M:%S"`
echo '--------------开始分库分表备份:开始时间为 '$TIME
for port in `ps -ef | grep mysql| grep socket| grep datadir| awk -F= '{print $NF}'`
  do
    BEGIN=`date "+%Y-%m-%d %H:%M:%S"`
    BEGIN_T=`date -d "$BEGIN" +%s`
    echo '备份'$port'端口号的mysql实例，开始时间为 '$BEGIN
    BACKUP_DIR=/data/backup/$DATE/$port;
    mkdir -p  $BACKUP_DIR;
    ##避免循环的port和sock不匹配
    sock=`ps -ef | grep mysql| grep socket| grep datadir|awk -F".pid" '{print $NF}'| grep $port`
    DB_PASSWORD='#Z8HJmwAJir@!y%9G%3pUEVY'  
    #过滤掉MySQL自带的DB
    for i in `/usr/local/mysql/bin/mysql -u$DB_USER -p$DB_PASSWORD  $sock -BN -e"show databases;" |sed '/^performance_schema$/'d|sed '/^mysql/'d |sed '/^information_schema$/'d|sed '/^information_schema$/'d|sed '/^test$/'d  `
    do
      sudo  /usr/local/mysql/bin/mysqldump -u$DB_USER -p$DB_PASSWORD $sock --master-data=2 -q  -c  --skip-add-locks  -R -E -B $i > $BACKUP_DIR/$date$i.sql
    done
    END=`date "+%Y-%m-%d %H:%M:%S"`
    END_T=`date -d "$END" +%s`
    TIME_INVENTAL_M=$[($END_T-$BEGIN_T)/60]
    TIME_INVENTAL_S=$[($END_T-$BEGIN_T)%60]
    echo '备份'$port'端口号的mysql实例于' $END '备份完成，使用时间为 '$TIME_INVENTAL_M'分钟'$TIME_INVENTAL_S'秒' >> /data/backup/$DATE/backup.log
         #备份文件的处理
         cd $BACKUP_DIR/..
         tar -zczf $port'_'$(date +%F_%H-%M).tar.gz $port
         #解压 tar -zvxf  $port.tar.gz
         rm -rf $port
done
TIME_END=`date "+%Y-%m-%d %H:%M:%S"`
echo '--------------backup all database successfully！！！结束时间:' $TIME_END
#删除7天以前的备份
find /data/backup/ -name '*'`date +%Y`'*' -type d -mtime  +7 -exec rm -rf  {} \;
