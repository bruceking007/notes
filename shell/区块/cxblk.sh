#!/bin/bash
#des:for query eth heigthblock
#date:2021-12-15
#cxblk.sh 调用 cxblknum.py

num1=$(geth attach /data/geth/data/geth.ipc --exec "eth.blockNumber")
num2=$(geth attach http://172.16.6.16:31652 --exec "eth.blockNumber")
sed -i "s/^BlkNum1=.*/BlkNum1=\'${num1}\'/g" /opt/scripts/cxblknum.py
sed -i "s/^BlkNum2=.*/BlkNum2=\'${num2}\'/g" /opt/scripts/cxblknum.py
#sed -i 's/^BlkNum=.*/BlkNum='"$num"'/g' /opt/scripts/cxblknum.py
/bin/python3 /opt/scripts/cxblknum.py

