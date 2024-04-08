#!/bin/bash
#set -x
bakDir='/home/backup/ldapbak'
mkdir -p $bakDir
slapcat -n 0 -l ${bakDir}/config.`date '+%Y-%m-%d'`.ldif
slapcat -n 2 -l ${bakDir}/data.`date '+%Y-%m-%d'`.ldif

find $bakDir/  -type f -name "*.ldif" -mtime +30 | xargs rm -f
