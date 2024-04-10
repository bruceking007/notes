#!/bin/bash
echo -e "\033[36m 清除登录成功日志，包含用户名、IP 地址和时间记录 \033[0m" && sleep 2
echo -e "\033[33m 清除之前 \033[0m" && sleep 2
last
cat /dev/null > /var/log/wtmp
echo -e "\033[33m 清除之后 \033[0m" && sleep 2
last

echo -e "\033[36m 清除登录失败日志，包含信息同上 \033[0m" && sleep 2
echo -e "\033[33m 清除之前 \033[0m" && sleep 2
lastb
cat /dev/null > /var/log/btmp 
echo -e "\033[33m 清除之后 \033[0m" && sleep 2
lastb


echo -e "\033[36m 清除各用户的最近登录日志 \033[0m" && sleep 2
echo -e "\033[33m 清除之前 \033[0m" && sleep 2
lastlog
cat /dev/null > /var/log/lastlog
echo -e "\033[33m 清除之后 \033[0m" && sleep 2
lastlog

echo -e "\033[36m 清除各类需要输入口令的登录日志 \033[0m" && sleep 2
echo -e "\033[33m 清除之前 \033[0m" && sleep 2
cat /var/log/secure
cat /dev/null > /var/log/secure
echo -e "\033[33m 清除之后 \033[0m" && sleep 2
cat /var/log/secure
