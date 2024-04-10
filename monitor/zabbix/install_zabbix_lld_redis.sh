#/bin/bash

cat > /usr/local/zabbix/bin/redis_port.py  <<EOF
#!/usr/bin/env python
import os
import json
t=os.popen("""netstat -natp|awk -F: '/redis-server/&&/LISTEN/{print \$2}'|awk '{print \$1}' """)
ports = []
for port in  t.readlines():
        r = os.path.basename(port.strip())
        ports += [{'{#REDISPORT}':r}]
print json.dumps({'data':ports},sort_keys=True,indent=4,separators=(',',':'))
EOF

cat > /usr/local/zabbix/bin/redis_stats.sh <<EOF
#!/bin/bash
METRIC="\$1"
HOSTNAME=127.0.0.1
PORT="\${2:-6379}"
CACHE_FILE="/tmp/redis_\$PORT.cache"

    (echo -en "INFO\r\n"; sleep 1;) | nc \$HOSTNAME \$PORT > \$CACHE_FILE 2>/dev/null || exit 1

grep "^\$METRIC:" \$CACHE_FILE |awk -F':|,' '{print \$2}'|sed "s/[^0-9]//g"
EOF

chmod +x /usr/local/zabbix/bin/redis_stats.sh
chmod +x /usr/local/zabbix/bin/redis_port.py



echo "UnsafeUserParameters=1"  >> /usr/local/zabbix/etc/zabbix_agentd.conf
echo "UserParameter=redis.discovery,python /usr/local/zabbix/bin/redis_port.py" >>  /usr/local/zabbix/etc/zabbix_agentd.conf
echo "UserParameter=redis_stats[*],(echo info; sleep 1) | telnet 127.0.0.1 \$1 2>&1 |grep \$2:|cut -d : -f2" >> /usr/local/zabbix/etc/zabbix_agentd.conf
/etc/init.d/zabbix_agentd restart
sleep 2

chmod +s /bin/netstat
#/usr/local/zabbix/bin/zabbix_get -s 127.0.0.1  -k redis_stats[6379,total_commands_processed]
