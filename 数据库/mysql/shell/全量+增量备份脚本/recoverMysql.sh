#!/bin/bash
#auth: kingofzhou
#date: 2019-08-22
#des: for recovey mysqlData

backDir=/data/dbbackup

#if [ ! -f $(date "+%y%m%d").tar.gz ];then
#	cd /data/dbbackup && tar czf $(date "+%y%m%d").tar.gz $(date "+%y%m%d")
#fi

function inc_rec() {
    ls -l $backDir
    echo -ne "\033[32m -->【请输入恢复时间的日期!】 \033[0m"
    read recDate
    ls -l $backDir/$recDate
    echo -ne "\033[32m -->【请输入恢复时间的目录名称!】 \033[0m"
    read last_incdir
    mydata='/data/mysql'
    basedir="/data/dbbackup/$recDate"
    full_basedir=$(cd $basedir && ls $basedir|head -n1)
    
    sleep 1 && echo -e "\033[32m 全量备份目录为 $full_basedir \033[0m"
    sleep 1 && echo -e "\033[32m 恢复时间目录为 $last_incdir \033[0m"
    
    for nowIncDir in `ls $basedir`
    do
            echo $nowIncDir
            if [ $nowIncDir == $full_basedir ];then #全量解压 
    		echo -e "\033[32m 预备完整备份 \033[0m" && sleep 3
                    innobackupex  --defaults-file=/etc/my.cnf --decompress $basedir/$full_basedir || exit 1
                    innobackupex --defaults-file=/etc/my.cnf --apply-log --redo-only $basedir/$full_basedir || exit 1
                    echo "full"
            elif [ $nowIncDir == $last_incdir ];then #判断是否为恢复的时间点，最后一次不需要加--redo-only参数
    		echo -e "\033[32m 合并最后一个增量备份 $last_incdir \033[0m" && sleep 3
                    innobackupex --defaults-file=/etc/my.cnf --apply-log $basedir/$full_basedir --incremental-dir=$basedir/$last_incdir || exit 1
    		break
            else
    		echo -e "\033[32m 合并增量备份 $nowIncDir \033[0m" && sleep 3
                    innobackupex --defaults-file=/etc/my.cnf --apply-log --redo-only  $basedir/$full_basedir --incremental-dir=$basedir/$nowIncDir || exit 1
    	fi
    done
    
    echo -e "\033[32m 停掉mysql服务 \033[0m" && sleep 2
    service mysql stop
    
    echo -e "\033[32m 备份原有数据库 \033[0m" && sleep 2
    cd $mydata && mv data data.bak`date "+%y%m%d%H%M"`
    
    echo -e "\033[32m 恢复完整备份 \033[0m" && sleep 2
    innobackupex --defaults-file=/etc/my.cnf --apply-log $basedir/$full_basedir || exit 1
    innobackupex --defaults-file=/etc/my.cnf --copy-back $basedir/$full_basedir || exit 1
    chown -R mysql.mysql $mydata/data
}

function full_rec() {
    ls -l $backDir
    echo -ne "\033[32m -->【请输入恢复时间的日期!】 \033[0m"
    read recDate
    ls -l $backDir/$recDate
    echo -ne "\033[32m -->【请输入恢复时间的目录名称!】 \033[0m"
    read full_basedir
    mydata='/data/mysql'
    basedir="/data/dbbackup/$recDate"

    echo -e "\033[32m 停掉mysql服务 \033[0m" && sleep 2
    service mysql stop

    echo -e "\033[32m 备份原有数据库 \033[0m" && sleep 2
    cd $mydata && mv data data.bak`date "+%y%m%d%H%M"`

    echo -e "\033[32m 预备完整备份 \033[0m" && sleep 3
    innobackupex  --defaults-file=/etc/my.cnf --decompress $basedir/$full_basedir || exit 1
    innobackupex --defaults-file=/etc/my.cnf --apply-log $basedir/$full_basedir || exit 1
    innobackupex --defaults-file=/etc/my.cnf --copy-back $basedir/$full_basedir || exit 1
    chown -R mysql.mysql $mydata/data
}

cat << EOF
+-------recoverMysql-------+
|1、 全量恢复              |
|2、 增量恢复              |
===========================|
|[Q|q|quit] to quit        |
+--------------------------+
EOF

echo -ne "\033[32m -->【请选择你要执行的选项编号!】 \033[0m"
read choice

case $choice in
    1)
      full_rec
      ;;
    2)
      inc_rec
      ;;
    Q|q|quit)
      exit
      ;;
    *)
      echo "程序异常退出,Please: select one number(1|2|3)"
      exit
      ;;
esac

