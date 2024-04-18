# ***\*docker or compose 部署mysql\****

## ***\*docker部署\****

docker run -d --name db-01 \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=123.com \
-v /etc/localtime:/etc/localtime \
-v mysql01_conf:/etc/mysql/conf.d \
-v mysql01_data:/var/lib/mysql \
-v mysql01_logs:/var/log \
mysql:5.7.32

## ***\*docker-compose部署\****

mkdir conf log
chown -R polkitd.root log/

version: '3'
services:
 mysql:
  image: mysql:5.7
  container_name: mysql_3306                  
  hostname: mysql
  restart: always                       
  privileged: true
  volumes:
   \- "/etc/localtime:/etc/localtime:ro"
   \- "./conf/my.cnf:/etc/mysql/my.cnf"
   \- "./data:/var/lib/mysql"
   \- "./log/mysqld:/var/log/mysqld"
   \- "./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d" # 可执行初始化sql脚本的目录 -- tips:`/var/lib/mysql`目录下无数据的时候才会执行(即第一次启动的时候才会执行)
  environment:             # 设置环境变量,相当于docker run命令中的-e
   TZ: Asia/Shanghai
   LANG: en_US.UTF-8
   MYSQL_ROOT_PASSWORD: root     # 设置root用户密码
   \#MYSQL_DATABASE: demo        # 初始化的数据库名称
  ports:                # 映射端口
   \- "3306:3306"

### ***\*vim conf/my.cnf\****

[client]
default-character-set = utf8

[mysqld]
character-set-server=utf8
log-bin=mysql-bin
server-id=1
pid-file     = /var/run/mysqld/mysqld.pid
socket      = /var/run/mysqld/mysqld.sock
datadir     = /var/lib/mysql
log_error=/var/log/mysqld/mysqld_error.log
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
symbolic-links=0
secure_file_priv =
wait_timeout=120
interactive_timeout=120
\#default-time_zone = '+8:00'
skip-external-locking
skip-name-resolve
open_files_limit = 10240
max_connections = 1000
max_connect_errors = 6000
table_open_cache = 800
max_allowed_packet = 40m
sort_buffer_size = 2M
join_buffer_size = 1M
thread_cache_size = 32
query_cache_size = 64M
transaction_isolation = READ-COMMITTED
tmp_table_size = 128M
max_heap_table_size = 128M
log-bin = mysql-bin
sync-binlog = 1
binlog_format = ROW
binlog_cache_size = 1M
key_buffer_size = 128M
read_buffer_size = 2M
read_rnd_buffer_size = 4M
bulk_insert_buffer_size = 64M
lower_case_table_names = 1
explicit_defaults_for_timestamp=true
skip_name_resolve = ON
event_scheduler = ON
log_bin_trust_function_creators = 1
innodb_buffer_pool_size = 512M
innodb_flush_log_at_trx_commit = 1
innodb_file_per_table = 1
innodb_log_buffer_size = 4M
innodb_log_file_size = 256M
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

\#slow_query
slow_query_log=ON
slow_query_log_file=/var/log/mysqld/mysql_slow_query.log
long_query_time=2

[client]
default-character-set = utf8

[mysqld]
character-set-server=utf8
log-bin=mysql-bin
server-id=1
pid-file     = /var/run/mysqld/mysqld.pid
socket      = /var/run/mysqld/mysqld.sock
datadir     = /var/lib/mysql
log_error=/var/log/mysqld/mysqld_error.log
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
symbolic-links=0
secure_file_priv =
wait_timeout=120
interactive_timeout=120
\#default-time_zone = '+8:00'
skip-external-locking
skip-name-resolve
open_files_limit = 10240
max_connections = 1000
max_connect_errors = 6000
table_open_cache = 800
max_allowed_packet = 40m
sort_buffer_size = 2M
join_buffer_size = 1M
thread_cache_size = 32
query_cache_size = 64M
transaction_isolation = READ-COMMITTED
tmp_table_size = 128M
max_heap_table_size = 128M
sync-binlog = 1
binlog_format = ROW
binlog_cache_size = 1M
key_buffer_size = 128M
read_buffer_size = 2M
read_rnd_buffer_size = 4M
bulk_insert_buffer_size = 64M
lower_case_table_names = 1
explicit_defaults_for_timestamp=true
skip_name_resolve = ON
event_scheduler = ON

server-id=1022

\#innodb
innodb_flush_log_at_trx_commit = 2
innodb_buffer_pool_size = 1G #20-65% memory
innodb_buffer_pool_instances = 8
\#innodb_lru_scan_depth = 2000 #ssd下配置2000以上
innodb_lock_wait_timeout = 60
\#innodb_io_capacity_max = 8000 #ssd 8000
innodb_io_capacity = 4000 
innodb_flush_method = O_DIRECT 
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
\#innodb_flush_neighbors = 0 #ssd
innodb_log_file_size = 256M
innodb_log_buffer_size = 16M
innodb_print_all_deadlocks = 1
innodb_strict_mode = 1
innodb_file_per_table = 1

\#binlog
log-bin = mysql-bin
log-slave-updates = 1  
binlog-format=row
sync-master-info = 1
expire_logs_days = 15
max_binlog_size = 100M 
log_bin_trust_function_creators=1
binlog_gtid_simple_recovery=1

\#slow_query
slow_query_log=ON
slow_query_log_file=/var/log/mysqld/mysql_slow_query.log
long_query_time=2

\#GTID 
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

windows

[mysqld]
port=63306
character_set_server=utf8
basedir=Y:\mysql-5.7.38-winx64
datadir=Y:\mysql-5.7.38-winx64\data
max_connections=1000
max_connect_errors=10
default-storage-engine=INNODB
server-id=1
skip_name_resolve = 1
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
lower_case_table_names=1
innodb_file_per_table = 1
log_timestamps=SYSTEM
log-error = error.log
slow_query_log = 1
slow_query_log_file = slow.log
long_query_time = 5
log-bin = binlog
binlog_format = row
expire_logs_days = 15
log_bin_trust_function_creators = 1
log-bin=Y:\mysql-5.7.38-winx64\logs\mysql-bin.log
log-error=Y:\mysql-5.7.38-winx64\logs\mysql_error.log

slow_query_log=ON
slow_query_log_file=Y:\mysql-5.7.38-winx64\logs\mysql_slow_query.log
long_query_time=2
\#skip-grant-tables

[client]
port=63306
default-character-set=utf8

### ***\*启动\****

chmod -R 777 log
chown -R polkitd.root log/
docker-compose up -d

https://gitee.com/zhengqingya/docker-compose/blob/master/Linux/mysql/docker-compose-mysql5.7.yml#

https://blog.51cto.com/riverxyz/2956641

https://zhuanlan.zhihu.com/p/550812951

https://blog.csdn.net/m0_67265464/article/details/124525899