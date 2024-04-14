#!/bin/bash
DATE=`date -d "15 days ago" +%Y.%m.%d`
echo $DATE
curl -s  -XGET http://127.0.0.1:9200/_cat/indices?v| grep $DATE | awk -F '[ ]+' '{print $3}' >/tmp/elk.log
for elk in `cat /tmp/elk.log`
do
        curl  -XDELETE  "http://127.0.0.1:9200/$elk"
done
