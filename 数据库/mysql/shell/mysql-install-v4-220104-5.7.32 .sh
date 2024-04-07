#!/bin/bash
#date:2021-11-23
#desc: for mysql install
#set -x
script_dir=$(cd $(dirname $0) && pwd)
cd $script_dir

blue() {
    echo -e "\033[34m $1  \033[0m" && sleep 1
}

red() {
    echo -e "\033[31m $1  \033[0m" && sleep 1
}

istMysql () {
	#安装必要软件包
	yum -y install numactl
	#创建相关目录
	blue "创建相关目录"
	mkdir -pv /data/mysql/{run,data,binlogs,log}
	#mkdir -pv /data/mysql/{redolog,undolog}
	
	blue "判断是否存在安装包"
	if [ -f mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz ];then
		echo -e "\033[32m mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz已存在 \033[0m"
	else
		echo -e "\033[32m mysql安装包不存在! 开始下载...... \033[0m" && wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz
	fi
	
	blue "解压并mv到指定目录"
	tar -xzvf mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz && mv mysql-5.7.32-linux-glibc2.12-x86_64/* /data/mysql
	
	#添加环境变量
	blue "添加环境变量"
	echo 'export PATH=$PATH:/data/mysql/bin' >> /etc/profile
	source /etc/profile
	
	#添加用户组, 创建mysql用户添加到mysql组
	blue "添加用户组, 创建mysql用户添加到mysql组"
	groupadd mysql
	useradd -g mysql mysql
	
	#设置mysql文件夹权限
	blue "设置mysql文件夹权限"
	chown -R mysql.mysql /data/mysql/
	#chown -R mysql.mysql /data/mysql/
	
	#mysql的服务脚本放到系统服务中
	blue "mysql的服务脚本放到系统服务中"
	cp -a /data/mysql/support-files/mysql.server  /etc/init.d/mysqld
	
	#配置文件修改
	blue "my.cnf配置文件修改"
	rm -f /etc/my.cnf
cat > /etc/my.cnf << EOF
[client]
#character_set_client = utf8
port = 12345
socket = /data/mysql/run/mysql.sock

[mysqld] 
port = 12345 
socket      = /data/mysql/run/mysql.sock
basedir = /data/mysql                                                                                  
datadir = /data/mysql/data                                                                             
pid-file = /data/mysql/run/mysql.pid
innodb_file_per_table = ON                                                                                                                                              
log-error=/data/mysql/log/mysql_error.log                                                              
lower_case_table_names=1
event_scheduler = 1
autocommit = 1
character_set_server = utf8
skip_name_resolve = 1
max_connections = 20000
max_connect_errors = 100
transaction_isolation = READ-COMMITTED
explicit_defaults_for_timestamp = 1
join_buffer_size = 8M #128GB
tmp_table_size = 64M  #128GB
max_allowed_packet = 128M #128GB
interactive_timeout = 7200 #s
wait_timeout = 7200  #s
read_buffer_size = 4M
read_rnd_buffer_size = 8M
sort_buffer_size = 4M

#slow_query
slow_query_log=ON
slow_query_log_file=/data/mysql/log/mysql_slow_query.log
long_query_time=2

#log
log_queries_not_using_indexes = 1
log_slow_admin_statements = 1
log_slow_slave_statements = 1
log_throttle_queries_not_using_indexes = 10
min_examined_row_limit = 100
log_timestamps=system

########replication settings########
master_info_repository = TABLE
sync_binlog = 1
relay_log_recovery = 1b 

#innodb
innodb_flush_log_at_trx_commit = 2
innodb_buffer_pool_size = 72G #20-65% memory
innodb_buffer_pool_instances = 8
innodb_lru_scan_depth = 2000 #ssd下配置2000以上
innodb_lock_wait_timeout = 60
innodb_io_capacity_max = 8000 #ssd 8000
innodb_io_capacity = 4000 
innodb_flush_method = O_DIRECT 
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_flush_neighbors = 0 #ssd
innodb_log_file_size = 140M
innodb_log_buffer_size = 16M
innodb_print_all_deadlocks = 1
innodb_strict_mode = 1
#innodb_log_group_home_dir = /data/mysql/redolog/
#innodb_undo_directory = /data/mysql/undolog/
#innodb_undo_log_truncate=1
#innodb_max_undo_log_size=2G



server-id=1022
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"


#binlog
log-bin=/data/mysql/binlogs/mysql-bin.log
log-slave-updates = 1  
binlog-format=row
sync-master-info = 1
sync_binlog = 1 #ssd
expire_logs_days = 10
max_binlog_size = 100M 
log_bin_trust_function_creators=1
binlog_gtid_simple_recovery=1

#GTID 
gtid-mode=on
enforce-gtid-consistency=on
master-info-repository=TABLE
relay-log-info-repository=TABLE
slave-parallel-workers=0
binlog-checksum=CRC32
master-verify-checksum=1
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
auto-increment-increment = 2
auto-increment-offset = 1
skip_slave_start=1
log_slave_updates=1
report-host=1.2.3.4
report-port=12345
EOF
	
	ibps=$(awk -v x=8 -v y=0.65 'BEGIN{printf "%.0f\n",x*y}')
	sed -i 's#innodb_buffer_pool_size = 72G#innodb_buffer_pool_size = '"$ibps"'G#g' /etc/my.cnf
	
	ip=`ip a|grep inet|grep global|awk '{print $2}'|awk -F/ '{print $1}'`
	sed -i 's#report-host=1.2.3.4#report-host='"$ip"'#g' /etc/my.cnf
	
	#查看mysql文件权限
	blue "查看mysql文件权限"
	ls -l /data/mysql/
	
	#初始化数据库
	blue "初始化数据库"
	cd /data/mysql/bin/ && ./mysqld --initialize --user=mysql --basedir=/data/mysql/--datadir=/data/mysql/data/
	
	#设置启动
	blue "设置启动"
	sleep 3
	\cp -fv /data/mysql/support-files/mysql.server /etc/init.d/mysql && chmod +x /etc/init.d/mysql
	chkconfig --add mysql && chkconfig --list mysql
	
	#touch  /data/mysql/mysqld.log && chown mysql.mysql /data/mysql/mysqld.log
	
	#启动
	blue "启动mysql"
	service mysqld start
	ps -ef|grep --color=auto mysql
	
	#临时密码
	blue "临时密码"
	DBPWD=$(grep 'temporary password' /data/mysql/log/mysql_error.log|awk '{print $NF}')
	echo "$DBPWD" > /tmp/pwtemp.txt && echo -e "\033[32m mysql临时密码为:$DBPWD 并且	密码保存在/tmp/pwtemp.txt。\033[0m"
	
	#mysql路径指定
	blue "mysql路径指定"
	ln -sfv /data/mysql/bin/mysql /usr/bin/mysql
}

mdmycnf () {
cat >> /etc/my.cnf << EOF

[mysqld_safe]
malloc-lib=/usr/lib64/libjemalloc.so.1
EOF

blue "重启mysql并且验证jemalloc是否生效"
service mysqld restart
lsof -n |grep jemalloc|grep mysql
}

#部署jemalloc
istJem () {
	blue "部署jemalloc"
	if test -d /usr/local/include/jemalloc;then
		blue "jemalloc已部署"
		red "检查是否设置软链接"
		if test -f /usr/lib64/libjemalloc.so.1;then
			blue "/usr/local/lib/libjemalloc.so.2 已软链接到 /usr/lib64/libjemalloc.so.1"
			red "jemalloc已完整部署" && mdmycnf && exit
		else
			red "未设置软链接,接下来设置！" && ln -sv /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
            mdmycnf && exit
		fi
	fi
	
	
	blue "安装 autogen autoconf"
	yum -y install autogen autoconf
	
	install () {
		cd $script_dir && tar -xf jemalloc-5.2.1.tar.bz2 && cd jemalloc-5.2.1
		./autogen.sh
		make -j4
		make install
		ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
		echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
		ldconfig
	}
	
	blue "下载and解压and部署"
	if test -f jemalloc-5.2.1.tar.bz2;then 
		install 
	else 
		while true; do
			#wget --no-check-certificate https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
			wget https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 -O $script_dir/jemalloc-5.2.1.tar.bz2
			if [ "$?" != 0 ];then 
				red "未下载成功，将继续尝试下载，请耐心等待！" 
			else 
				blue "下载成功,开始部署！"
				install && mdmycnf
				break
			fi
		done
	fi
}

main (){
istMysql
istJem
}

main "$@"