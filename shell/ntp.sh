#!/bin/bash
#date: 2019-07-01
#desc: For sync time


set -x
service ntpd stop
arrNTP=(ntp.cloud.aliyuncs.com time1.google.com stdtime.gov.hk)
mkdir -p /tmp/logs/ntptime

for time in "${arrNTP[@]}"
do
	find /tmp/logs/ntptime/ -type f -name "*.log" -mtime +1 -exec rm -f {} \;
	/usr/sbin/ntpdate $time >> /tmp/logs/ntptime/time_`date +%F`.log
	if [ $? -eq 0 ];then
		exit 1
	fi
done

