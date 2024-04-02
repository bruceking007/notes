#!/usr/bin/bash
echo '======================================================='
echo '统计重试登陆的次数，能看到哪些IP及哪些用户在恶意登陆系统'
lastb root | awk '{print $3}' | sort | uniq -c | sort -nr| more
echo '======================================================='
echo '检查是否有新用户尤其是UID和GID为0的用户' 
awk -F":" '{if($3 == 0){print $1}}' /etc/passwd 
echo '======================================================='
echo '检查是否存在空口令账户'
awk -F: '{if(length($2)==0) {print $1}}' /etc/passwd 
echo '======================================================='
echo ' 检查一下 SUID的文件'
find / -uid 0 -perm 4000 -print
echo '======================================================='
echo ' 检查空格文件'
 find / -name "..." -print 
 find / -name ".. " -print 
 find / -name "." -print 
 find / -name " " -print 
echo '======================================================='
echo '检查隐藏进程'
ps -ef | awk '{print $2}'| sort -n | uniq >1; ls /proc |sort -n|uniq >2;diff -y -W 40 1 2
echo '======================================================='
echo '检查恶意程序开放的端口及打开的文件'
netstat -ntulp
echo '======================================================='
echo '检查系统计划任务'
crontab -u root -l 
cat /etc/crontab 
ls /etc/cron.* 
echo '======================================================='
echo '查看所有的可用单元'
systemctl list-unit-files|grep enabled
echo '======================================================='
echo '检查rootkit'
if [ `yum list installed|grep rkhunter|wc -l` -eq 0 ];then
yum install rkhunter -y >/dev/null
echo 'install rkhunter success' 
fi
rkhunter --check --skip-keypress|grep 'Warning'
echo '======================================================='
