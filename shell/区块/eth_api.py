#!/bin/python3
# -*- encoding: utf-8 -*-
import requests
import json
ori=requests.get('https://api.etherscan.io/api?module=proxy&action=eth_blockNumber') #调用api接口
data=json.loads(ori.text)
blkNum=int(data['result'],16) #16进制转10进制
print(blkNum)
