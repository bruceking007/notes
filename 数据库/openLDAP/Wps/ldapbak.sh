#!/bin/bash
set -x
bakDir='/home/codeBack/ldapbak'
mkdir -p $bakDir
date=`date +%Y%m%d_%H%M%S`
backFile=ldapback_${date}.ldif
slapcat -v -l ${bakDir}/${backFile}

find $bakDir/  -type f -name "*.ldif" -mtime +30 -exec rm -rf {} \;
