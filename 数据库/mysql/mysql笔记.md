不建议大家在项目中直接使用 `root` 超级管理员账号访问数据库，这样做实在是太危险了。我们可以使用下面的命令创建名为 `guest` 的用户并为其授权

```
create user 'guest'@'%' identified by 'Guest.618';
grant insert, delete, update, select on `hrs`.* to 'guest'@'%';
```



#### 1、创建 utf8 数据库

```sql
CREATE DATABASE IF NOT EXISTS nacos_config DEFAULT CHARSET utf8 COLLATE utf8_general_ci

----------
CREATE DATABASE `idp_app` CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
CREATE DATABASE `idp_sdk` CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci';
```



#### 2、创建备份用户

根据备份场景不同，创建的用户权限也不同。

##### 2.1

使用自带的备份命令(如： `mysqldump`, `mysqlpump`, `mydumper`)的逻辑备份：

- SELECT: 查询表中数据
- SHOW VIEW: 查看创建视图的语句
- TRIGGER: 备份触发器
- EVENT : 备份事件（定时任务）
- lock tables: 备份时锁表，产生一致性备份
- reload: `show processlist` , `show engine innodb status` , 查看线程， 查看引擎状态
- replication client: `show master/slave status;` 查看事务日志执行状态与位置 `show binary logs`；查看当前保存的事务日志列表与文件大小
- super : 关闭线程，不受最大连接线程数限制的VIP连接通道，阻断刷新线程的命令，不受离线模式影响

```sql
CREATE USER 'backup'@'%' IDENTIFIED BY 'password';

/* Grant all privileges on *.* to 'backup'@'%' with grant option; */
#5.7
grant select,lock tables,show view,trigger,event on database.* to 'backup'@'%';

#8.0
grant select,lock tables,show view,trigger,event,process  on *.* to 'backup'@'%';

ALTER USER 'backup'@'%' IDENTIFIED BY 'password';
```

###### 2.1.1

```
grant select, show view ,trigger ,event ,lock tables, process, reload, replication client, super on *.* to backup@localhost identified by 'xxxxxxx';  
flush privileges;  
```

###### 2.1.2

```
create user 'back'@'localhost' identified by '123456';
grant reload,lock tables,replication client,create tablespace,process,super on *.* to 'back'@'localhost' ;
grant create,insert,select on percona_schema.* to 'back'@'localhost';
```

##### 2.2 第三方备份工具, 如 `innobackupex`，`MySQL Enterprise Backup` 等

- lock tables: 备份时锁表，产生一致性备份

- reload: `flush table/host/logs/tables/status/threads/refresh/reload`，所有的flush操作。用于锁表，切割日志，更新权限

- process: `show processlist` , `show engine innodb status` ,查看线程，查看引擎状态

- replication client: `show master/slave status;` 查看事务日志执行状态与位置 `show binary logs`；查看当前保存的事务日志列表与文件大小

- super: super权限很多很多，但是没有CURD（增删改查权限），这里点到为止说一下和备份相关的起停复制线程，切换主库位置，更改复制过滤条件，清理二进制日志，赋予账户视图与存储过程的DEFINER权限，创建链接服务器（类似于MSSQL的订阅服务器），关闭线程，不受最大连接线程数限制的VIP连接通道，阻断刷新线程的命令，不受离线模式影响。

  ```
  grant lock tables, reload, process, replication client, super on *.* to backup@localhost identified by 'xxxxxxx';  
  flush privileges;  
  ```

  ## 说明

  - 逻辑备份的基本原理就是数据全部读取，必须select与show权限，查看表定义的权限由select权限提供
  - super 权限可以防止因为线程满，备份任务无法连接数据库而导致的备份翻车。且阻断刷新线程也是很重要
  - `innobackupex` 主要以物理文件和备份缓存文件的方式进行，所以不需要show权限与select权限

  ##### 

  https://www.lshell.com/posts/create-least-privileged-mysql-backup-user/

  



最近发现 MySQL 8.0 中具有特殊功能的数据库无法备份。这是由于 MySQL 8.0 在处理特定类型的数据时发生了变化。MySQL 文档声明如下： 

> **不兼容的更改：** 现在访问表 [`INFORMATION_SCHEMA.FILES`](https://dev.mysql.com/doc/refman/5.7/en/information-schema-files-table.html) 需要 [`PROCESS`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_process) 特权。
>
>  
>
> 此更改会影响 **mysqldump** 命令的用户，该命令访问表中的表空间信息 [`FILES`](https://dev.mysql.com/doc/refman/5.7/en/information-schema-files-table.html)，因此现在 [`PROCESS`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_process) 也需要该权限。不需要转储表空间信息的用户可以通过使用该选项调用 **mysqldump** [`--no-tablespaces`](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html#option_mysqldump_no-tablespaces) 来解决此要求。（错误 [#30350829](https://support.cpanel.net/agent/tickets/30350829)）



[备份报错](https://support.cpanel.net/hc/en-us/articles/4408836702999-WPToolkit-error-during-backup-mysqldump-Error-Access-denied-you-need-at-least-one-of-the-PROCESS-privilege-s-for-this-operation-when-trying-to-dump-tablespaces-)





#### 3、修改数据库密码

- mysql8 之前

```text
set password for 用户名@localhost = password('新密码'); 
mysqladmin -u用户名 -p旧密码 password 新密码  
update user set password=password('123') where user='root' and host='localhost';
```

- mysql8 之后

```text
# mysql8初始对密码要求高，简单的字符串不让改。先改成:MyNewPass@123;
alter user 'root'@'localhost' identified by 'MyNewPass@123';
# 降低密码难度
set global validate_password.policy=0;
set global validate_password.length=4;
# 修改成简易密码
alter user 'root'@'localhost'IDENTIFIED BY '1111';  
```

#### 4、数据库中间件 Mycat 的安装使用

[数据库中间件 Mycat 的安装使用](https://www.ssgeek.com/post/shu-ju-ku-zhong-jian-jian-mycat-de-an-zhuang-shi-yong/)



#### 5、MySQL备份之Xtrabackup

[MySQL备份之Xtrabackup](https://www.ssgeek.com/post/mysql-bei-fen-zhi-xtrabackup/#5-%E7%94%9F%E4%BA%A7%E6%A1%88%E4%BE%8B)

#### 6、mysql分库备份与分表备份

https://www.ssgeek.com/post/mysql-fen-ku-bei-fen-yu-fen-biao-bei-fen/

##### 1、分库备份

要求：将mysql数据库中的用户数据库备份，备份的数据库文件以时间命名
脚本内容如下：

```shell
#!/bin/bash
mysql_user=root
mysql_pass=123456
mkdir -p /backup
for n in `mysql -u$mysql_user -p$mysql_pass -e 'show databases;' 2>/dev/null|grep -Ev '_schema|mysql'|sed '1d'`;
do
	mysqldump -u$mysql_user -p$mysql_pass -B $n 2>/dev/null>/backup/${n}_`date +%Y_%m_%d`.sql
done
```

执行脚本进行测试：

```shell
[root@db01 scripts]# sh -x backup_database.sh 
+ mysql_user=root
+ mysql_pass=123456
+ mkdir -p /backup
++ mysql -uroot -p123456 -e 'show databases;'
++ grep -Ev '_schema|mysql'
++ sed 1d
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 -B test1
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 -B test2
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 -B test
[root@db01 scripts]# 
```

检查备份情况：

```shell
[root@db01 scripts]# tree /backup/
/backup/
├── test1_2018_07_04.sql
├── test2_2018_07_04.sql
└── test_2018_07_04.sql

0 directories, 3 files
[root@db01 scripts]# 
```

##### 2、分库分表备份

要求：备份每个数据库的表，同一个库中的表，放在对应数据库名字命名的目录下
脚本内容如下：

```shell
[root@db01 scripts]# vim backup_tables.sh
#!/bin/bash
mysql_user=root
mysql_pass=123456
mkdir -p /backup
for n in `mysql -u$mysql_user -p$mysql_pass -e 'show databases;' 2>/dev/null|grep -Ev '_schema|mysql'|sed '1d'`;
do
	mkdir -p /backup/$n
	for m in `mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '1d'`;
	do
		mysqldump -u$mysql_user -p$mysql_pass $n $m 2>/dev/null>/backup/${n}/${m}_`date +%Y_%m_%d`.sql
	done
done
```

执行脚本进行测试：

```shell
[root@db01 scripts]# sh -x backup_tables.sh 
+ mysql_user=root
+ mysql_pass=123456
+ mkdir -p /backup
++ mysql -uroot -p123456 -e 'show databases;'
++ grep -Ev '_schema|mysql'
++ sed 1d
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mkdir -p /backup/test1
++ sed 1d
++ mysql -uroot -p123456 test1 -e 'show tables;'
+ for m in '`mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 test1 students
+ for m in '`mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 test1 test
+ for m in '`mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 test1 test2
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mkdir -p /backup/test2
++ mysql -uroot -p123456 test2 -e 'show tables;'
++ sed 1d
+ for m in '`mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 test2 test3
+ for n in '`mysql -u$mysql_user -p$mysql_pass -e '\''show databases;'\'' 2>/dev/null|grep -Ev '\''_schema|mysql'\''|sed '\''1d'\''`'
+ mkdir -p /backup/test
++ mysql -uroot -p123456 test -e 'show tables;'
++ sed 1d
+ for m in '`mysql -u$mysql_user -p$mysql_pass $n -e "show tables;" 2>/dev/null|sed '\''1d'\''`'
+ mysqldump -uroot -p123456 test test4
[root@db01 scripts]# 
```

检查备份情况：

```shell
[root@db01 scripts]# tree /backup/
/backup/
├── test1
│   ├── students_2018_07_04.sql
│   ├── test_2018_07_04.sql
│   └── test2_2018_07_04.sql
├── test2
│   └── test3_2018_07_04.sql
└── test
    └── test4_2018_07_04.sql

3 directories, 5 files
[root@db01 scripts]# 
```

