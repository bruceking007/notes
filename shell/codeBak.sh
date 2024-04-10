#!/bin/bash
#date: 2019-07-01
#desc: For code backup
set -x

function javaBak () {
	backDir='/home/backup/javabak'
	date=`date +%F_%H%M%S`

	arrJava=(`ls /home/java`)

	[ ! -d $backDir ] && mkdir -p $backDir

	for value in "${arrJava[@]}"
	do
		echo $value
		if [ -d /home/java/$value ];then
			cd /home/java && tar czf $backDir/${value}_${date}.tar.gz --exclude=logs --exclude=bak --exclude=backup --exclude=*.gz --exclude=*.war --exclude=*.out ${value}
			find /home/java/${value}/logs -type f -name "*" -mtime +14 -exec rm -f {} \;
		fi
	done

	find $backDir/  -type f -name "*.gz" -mtime +7 -exec rm -rf {} \;
	chown -R tom.tom $backDir
}

function ngBak () {
	backDir='/home/backup/ngbak'
	date=`date +%F_%H%M%S`

	[ ! -d $backDir ] && mkdir -p $backDir

	[ -d /usr/local/nginx ] && cd /usr/local/nginx && tar czf $backDir/conf_${date}.tar.gz  conf
        find $backDir/  -type f -name "*.gz" -mtime +14 -exec rm -rf {} \;
}

main () {
	javaBak
	ngBak
}

main "$@"
