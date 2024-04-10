#!/bin/python3
# -*- encoding: utf-8 -*-
import os
import sys
import time
from datetime import *
from telegram import Bot
import requests
import json

NowTime=(datetime.now() + timedelta(minutes=10)).strftime("%H:%M")
bot = Bot(token = "1631871208:AAEGr-xV0De_MxcF7wc7rgc-PSmrGk0L70k")
#content = sys.argv[1]
#content='【发布提醒】project %s将例行发包，请知' % NowTime
BlkNum1='13813825'
BlkNum2='13813825'
IP=os.popen("curl -s ifconfig.me").read()
#bot.send_message("-686484505", 'IP为' +  ' ' + GetIp + 'eth当前区块高度为' + ' ' + content)

ori=requests.get('https://api.etherscan.io/api?module=proxy&action=eth_blockNumber') #调用api接口
data=json.loads(ori.text)
mainblkNum=str(int(data['result'],16)) #16进制转10进制

content1=('主网eth当前区块高度=%s' % mainblkNum)
content2=('%s eth当前区块高度=%s' % (IP,BlkNum1))
content3=('47.243.7.65(备) eth当前区块高度=%s' % BlkNum1)
bot.send_message("-686484505", content1 + '\n' + content2 + '\n' + content3)

#bot.send_message("-686484505", '主网eth当前区块高度' + '=' + mainblkNum + '\n'
#+ IP + ' ' + 'eth当前区块高度' + '=' + BlkNum1 + '\n'
#+ '47.243.7.65' + ' ' + 'eth当前区块高度' + '=' + BlkNum2)

#bot.send_message("-686484505", '主网eth当前区块高度' + '=' + mainblkNum )
#bot.send_message("-686484505", IP + ' ' + 'eth当前区块高度' + '=' + BlkNum1 )
#bot.send_message("-686484505", '47.243.7.65' + ' ' + 'eth当前区块高度' + '=' + BlkNum2 )
