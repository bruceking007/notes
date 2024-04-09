#/bin/bash
export LANG=en_US.utf8
BAKBASEDIR="/home/databackup"
export PGPASSWORD='^regex$'
PG_DUMP=/usr/local/pgsql/bin/pg_dump
date=`date +%F_%H%M%S`

if [ ! -d $BAKBASEDIR ];then
        mkdir -p $BAKBASEDIR
fi
cd $BAKBASEDIR

echo "Backup start: `date +%Y%m%d_%H:%M:%S`"  > bakRcord_${date}.log
$PG_DUMP  -p 5432 -U GPO GPO  | gzip > GPO_${date}.gz
if [ $? -eq 0 ];then
        echo  "GPO_${date}.bak_sucess" >> bakRcord_${date}.log
      else
        echo  "GPO_${date}.bak_fail" >> bakRcord_${date}.log
fi
echo "Backup end: `date +%Y%m%d_%H:%M:%S`" >> bakRcord_${date}.log

find /home/databackup/ -type f -name "*" -mtime +15 -exec rm -rf {} \;
chown -R postgres.postgres /home/databackup/

