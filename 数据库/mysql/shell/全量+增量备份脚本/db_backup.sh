#!/bin/bash
set -x
mkdir -p /data/dbbackup/{logs,tarfiles}
basedir="/data/dbbackup/$(date "+%y%m%d")"
sock=$(ps -ef|grep mysql|grep datadir|awk -F".pid" '{print $NF}'|awk  '{print $1}')
pw='123.com'

function full_backup() {
	if [ ! -d $basedir ];then
		BEGIN=`date "+%Y-%m-%d %H:%M:%S"`
		BEGIN_T=`date -d "$BEGIN" +%s`
		innobackupex --defaults-file=/etc/my.cnf --user=root --password=${pw} ${sock} --compress $basedir  &>> "/data/dbbackup/logs/$(date "+%y%m%d%H%M").log"
		END=`date "+%Y-%m-%d %H:%M:%S"`
		END_T=`date -d "$END" +%s`
		TIME_INVENTAL_M=$[($END_T-$BEGIN_T)/60]
		TIME_INVENTAL_S=$[($END_T-$BEGIN_T)%60]
	
		#echo '备份'$port'端口号的mysql实例于' $END '备份完成，使用时间为 '$TIME_INVENTAL_M'分钟'$TIME_INVENTAL_S'秒' >> /data/dbbackup/logs/$(date "+%y%m%d").log
		echo 'mysql实例于' $END '全量备份完成，使用时间为 '$TIME_INVENTAL_M'分钟'$TIME_INVENTAL_S'秒' >> /data/dbbackup/logs/$(date "+%y%m%d%H%M").log
		full_basedir=$(cd $basedir && ls $basedir|head -n1)
		cd $basedir && tar czf /data/dbbackup/tarfiles/${full_basedir}_full.tar.gz ${full_basedir} 
	else 
		dirCount=`ls -A ${basedir} |wc -w`
		if [ $dirCount -gt 0 ];then
			dateLog="/data/dbbackup/logs/$(date "+%y%m%d%H%M").log"
                    arrBakDir=(`ls -r $basedir`)
                    for value in "${arrBakDir[@]}"
                    do
                        if [ ! -f $basedir/$value/xtrabackup_checkpoints ];then #删除备份失败的
                            rm -rf $basedir/$value
                        fi
                    done

                    add_basedir="$basedir/`ls $basedir|tail -n1`"

                	BEGIN=`date "+%Y-%m-%d %H:%M:%S"`
                	BEGIN_T=`date -d "$BEGIN" +%s`
                	innobackupex --defaults-file=/etc/my.cnf --user=root --password=${pw} ${sock} --incremental-basedir="$add_basedir" --incremental $basedir  &>> $dateLog
                	END=`date "+%Y-%m-%d %H:%M:%S"`
                	END_T=`date -d "$END" +%s`
                	TIME_INVENTAL_M=$[($END_T-$BEGIN_T)/60]
                	TIME_INVENTAL_S=$[($END_T-$BEGIN_T)%60]

                	echo 'mysql实例于' $END '增量备份完成，使用时间为 '$TIME_INVENTAL_M'分钟'$TIME_INVENTAL_S'秒' >> $dateLog
                	inc_basedir=$(cd $basedir && ls $basedir|tail -n1)
                	#cd $basedir && tar czf /data/dbbackup/tarfiles/${inc_basedir}_inc.tar.gz ${inc_basedir}
		else 
			exit 1
		fi
		
	fi

}

full_backup
find /data/{dbbackup,dbbackup/tarfiles,dbbackup/logs} -maxdepth 1  -name "*" -mtime +6 -exec rm -rf {} \;
