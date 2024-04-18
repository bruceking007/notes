#### 0、Bash 备忘清单

```
https://quickref.cn/docs/bash.html
```



#### 1、set 参数使用

```
set -euo pipefail 的作用:
set -e: 脚本中有任何一条命令执行失败, 整个脚本就失败
set -u: 脚本中的变量有任何一个变量为空, 整个脚本执行失败
-o pipefail: 脚本中的管道中任何一条命令执行失败, 也会认为脚本执行失败
```

```shell
#!/bin/bash
set -euo pipefail
```



#### 2、删除旧备份脚本

```shell
ReservedNum=5  #保留文件数
FileDir=${WORKSPACE}/bak/
date=$(date "+%Y%m%d-%H%M%S")

cd $FileDir   #进入备份目录
FileNum=$(ls -l | grep '^d' | wc -l)   #当前有几个文件夹，即几个备份

while(( $FileNum > $ReservedNum))
do
    OldFile=$(ls -rt | head -1)         #获取最旧的那个备份文件夹
    echo  $date "Delete File:"$OldFile
    rm -rf $FileDir/$OldFile
    let "FileNum--"
done 
```



#### 3、获取namesilo域名列表

按创建时间从新到旧排列

```shell
apiKey='xxxxxxxxxxx'
#获取xml格式域名列表
curl -s "https://www.namesilo.com/api/listDomains?version=1&type=xml&key=${apiKey}&withBid=1&pageSize=" > 1.txt

#格式化xml数据
xmllint --format 1.txt > 2.xml

#获取domains之间的内容
sed -n "/domains/,/\/domains/p" 2.xml > 3.xml

#删除domains
sed -i '/domains/d' 3.xml
sort -t '"' -k 2 -r 3.xml > 4.xml
awk -F '<' '{print $2}' 4.xml |awk -F '>' '{print $2}' > domains.txt
```



```shell
apiKey='xxxxxxxxxxxxx'
curl -s "https://www.namesilo.com/api/listDomains?version=1&type=xml&key=${apiKey}&withBid=1&pageSize=" > 1.txt
xmllint --format 1.txt | sed -n "/domains/,/\/domains/p" > 1.html
sort -t '"' -k 2 -r 1.html |awk -F '<' '{print $2}'  |awk -F '>' '{print $2}' > domains.txt
```



#### 4、cloudflare添加域名并修改nameserver

```
CF_API_EMAIL='xxxxxxx@xxxxx.com'
CF_API_KEY='xxxxxxxxxxxxx

add() {
    for domain in $(cat domain.txt); do \
                curl -X POST -H "X-Auth-Key: $CF_API_KEY" -H "X-Auth-Email: $CF_API_EMAIL" \
                -H "Content-Type: application/json" \
                "https://api.cloudflare.com/client/v4/zones" \
                --data '{
                "account": {
                                "id": "122388db36cdcaa33b97fd5ea2117b76",
                                "name":"OneCloud Enterprise account"
                },
                "name": "'$domain'",
                "jump_start": "true",
                "type": "full"
                }'  > ./logs/${domain}.log
    done
}

ns() {
    curl -X GET -H "X-Auth-Key: $CF_API_KEY" -H "X-Auth-Email: $CF_API_EMAIL" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones/2b1fb52c43efa22e7fb8745c104ae981"
}

add
#ns
```

for jenkins1

```shell
#cloudflare
export CF_API_EMAIL='xxxxxxxxxx@xxxx.com'
export CF_API_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#namesile
apiKey='xxxxxxxxxxxxx

for domain in ${domains}; do \
			echo "===================================【CloudFlare添加$domain开始】==================================="
            #echo -e “\033[34m ===================================【CloudFlare添加$domain开始】=================================== \033[0m”
            echo "\n"
            curl -X POST -H "X-Auth-Key: $CF_API_KEY" -H "X-Auth-Email: $CF_API_EMAIL" \
            -H "Content-Type: application/json" \
            "https://api.cloudflare.com/client/v4/zones" \
            --data '{
            "account": {
                            "id": "122388db36cdcaa33b97fd5ea2117b76",
                            "name":"OneCloud Enterprise account"
            },
            "name": "'$domain'",
            "jump_start": "true",
            "type": "full"
            }' 
			echo "===================================【NameSilo修改$domain NameServer开始】==================================="
            #echo -e “\033[34m ===============【NameSilo修改$domain NameServer开始】=============== \033[0m”
			#获取nameserver并修改nameserver
            flarectl zone info --zone=${domain}
			NS1=$(flarectl zone info --zone=${domain}|awk -F '|' '{print $5}'|egrep -v "^$|NAME"|sed 's/,//g'|awk '{gsub(/^\s+|\s+$/, "");print}'|head -n1)
			NS2=$(flarectl zone info --zone=${domain}|awk -F '|' '{print $5}'|egrep -v "^$|NAME"|sed 's/,//g'|awk '{gsub(/^\s+|\s+$/, "");print}'|tail -n1)
			curl -s "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${apiKey=}&domain=${domain}&ns1=${NS1}&ns2=${NS2}"
done
```



for jenkins2

```shell
#cloudflare
export CF_API_EMAIL='xxxxxxxxxxxx@xxxx.com'
export CF_API_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
accountId='xxxxxxxxxxxxxx

#namesile
apiKey='xxxxxxxxxxxxxxxx'

for domain in ${domains}; do \
			echo "===================================【CloudFlare添加$domain开始】==================================="
            #echo -e “\033[34m ===================================【CloudFlare添加$domain开始】=================================== \033[0m”
            echo "\n"
			flarectl zone create --account-id=${accountId} --zone=${domain} --jumpstart=true
			echo "===================================【NameSilo修改$domain NameServer开始】==================================="
            #echo -e “\033[34m ===============【NameSilo修改$domain NameServer开始】=============== \033[0m”
			#获取nameserver并修改nameserver
            flarectl zone info --zone=${domain}
			NS1=$(flarectl zone info --zone=${domain}|awk -F '|' '{print $5}'|egrep -v "^$|NAME"|sed 's/,//g'|awk '{gsub(/^\s+|\s+$/, "");print}'|head -n1)
			NS2=$(flarectl zone info --zone=${domain}|awk -F '|' '{print $5}'|egrep -v "^$|NAME"|sed 's/,//g'|awk '{gsub(/^\s+|\s+$/, "");print}'|tail -n1)
			curl -s "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${apiKey=}&domain=${domain}&ns1=${NS1}&ns2=${NS2}"
done
```



#### 5、添加cloudflare解析记录

for jenkins

```shell
export CF_API_EMAIL='xxxxxxxxx@xxxx.com'
export CF_API_KEY='xxxxxxxxxxxxxxxxxxxxxxxx'
echo "解析的根域名为：---》 $domain"
echo "解析的类型为：---》 $type"
echo "解析的名称为：---》 $name"
realContent=$(echo $target|awk -F '=' '{print $NF}')
echo "解析的内容为：---》 $realContent"

if  [ ! -n "$domains" -o ! -n "$type" -o ! -n "$name" -o ! -n "$realContent" ] ;then
    echo “输入的4个参数都不能为空，请检查！”
    exit 1
fi

for domain in ${domains};do
		flarectl dns create --zone="${domain}" --name="${name}" --type="$type" --content="${realContent}"
done
#ping -c 1 -w 1 ${name}.${domain}
```

#### 6、颜色设置

```
##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

echoRed "===================【分割线】====================="
echoGreen "===================【分割线】====================="
echoYellow "===================【分割线】====================="

```

```
#!/bin/bash
#定义颜色变量
BLACK='\e[1;30m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
PURPLE='\e[1;35m'
PINK='\e[1;36m'
WHITE='\e[1;37m'
END='\e[0m'

#需要使用echo -e
echo -e  "${BLACK}##########黑色##########${END}"
echo -e  "${RED}##########红色##########${END}"
echo -e  "${GREEN}##########绿色##########${END}"
echo -e  "${YELLOW}##########黄色##########${END}"
echo -e  "${BLUE}##########蓝色##########${END}"
echo -e  "${PURPLE}##########紫色##########${END}"
echo -e  "${PINK}##########粉色##########${END}"
echo -e  "${WHITE}##########白色##########${END}"
echo "--------------------------------------------"


#写成函数，直接调用
SETCOLOR_SUCCESS() { echo $'\e[1;32m'"$1"$'\e[0m'; }
SETCOLOR_FAILURE() { echo $'\e[1;31m'"$1"$'\e[0m'; }
SETCOLOR_WARNING() { echo $'\e[1;33m'"$1"$'\e[0m'; }
SETCOLOR_NORMAL() { echo $'\e[1;39m'"$1"$'\e[0m'; }

SETCOLOR_SUCCESS "------成功了------！"
SETCOLOR_FAILURE "------失败了------！"
SETCOLOR_WARNING "------有告警------！"
SETCOLOR_NORMAL "------正常的------！"
```



#### 7、grep技巧

https://blog.51cto.com/knifeedge/5141009

```
curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d'
grep -Po 'Congratulations! You have successfully enabled HTTPS on \K.*\w' log

###
"tag_name": "
Congratulations! You have successfully enabled HTTPS on 
以上都是作为单独的过滤字符串
```

- -P perl正则

- \K 否 使\K左边的文本不匹配

- \d 是 匹配任何数字字符

  

#### 8、while 循环使用技巧

```shell
while true;do 
  certnum=$(ps -ef|grep certbot|grep -v grep|wc -l)
  if [ $certnum -eq 0 ];then
        fun_certbot
        #break
  fi
  sleep 3
done
```



#### 9、telegrambot

```
https://baiyue.one/archives/1507.html
```





#### 10、循环计数

```shell
#!/bin/bash
rm -f cp-oss.log
declare num1=0
logFile=cp-oss.log
cat 1529.txt |while read line
do
  let num1=$num1+1
  echo $num1 >> ${logFile}
  echo "*************************" >> ${logFile}
  echo $line >> ${logFile}
  $line >> ${logFile} 2>&1
done
```



usage

```shell
function usage(){
    echo "运行脚本需要两个参数, 一个是编号, 一个是域名!"
    echo "Usage: `basename $0` p3 p3.xxxx.com"
    exit 0
}

if [ "$#" -ne 2 ];then usage;fi
if [[ "$#" == "--help" || "$#" == "-h" ]];then usage;fi
```



#### 11、sed

- ##### sed 删除匹配行之间的内容


比如删除2023-10-01 start 和2023-10-01 end之间的内容

```
#删除匹配项
sed   '/2023-10-01 start/,/2023-10-01 end/d' GeoLite

#不删除匹配项
sed   '/2023-10-01 start/,/2023-10-01 end/{/2023-10-01 start/!{/2023-10-01 end/!d}}' GeoLite  

```



- ##### sed 在这个文里 Root 的一行，匹配 Root 行，将 no 替换成 yes

```
sed -i '/Root/s/no/yes/' /etc/ssh/sshd_config 
```



- **使用sed命令批量替换某个目录下文件的内容**

```
sed -i "s/原字符串/新字符串/g" `grep 原字符串 -rl 所在目录`
```



#### 12、判断变量是否为空

https://blog.csdn.net/varyall/article/details/79140753

```shell
if  [ ! -n "$domains" -o ! -n "$type" ] ;then
    echoRed "输入的参数都不能为空，请检查！"
    exit 1
fi

=====
if [ $content ] && [ $name ];then echoRed "输入的参数不能同时存在，请检查！" && exit 1;fi
if [ ! $content ] && [ ! $name ];then echoRed "输入的参数不能同时为空，请检查！" && exit 1;fi

=====
if [ $name ] && [ ! $content ];then echo "name";fi  #name不为空，content为空的情况下
if [ $content ] && [ ! $name ];then echo "content";fi #content不为空，name为空的情况下
```



#### 13、if and or

https://blog.csdn.net/lanyang123456/article/details/57416906



#### 14、for 的巧用

```
cd /usr/local/mysql/bin
for i in *
do
ln /usr/local/mysql/bin/$i /usr/bin/$i
done
```

注意：给 MySQL 建软链接。



#### 15、shell脚本中设定时间限制并在一定时间后停止循环进程

https://www.volcengine.com/theme/5444778-R-7-1

```
timeout 10s bash 循环进程.sh
```

```
SECONDS=0
while (( SECONDS < 60)); do
    x=$(/opt/oc get pods --selector app=${bamboo.shortPlanName} -o jsonpath='{range .items[]}{.status.phase}{"\n"}{end}')
    if [[ $x == Running ]]; then
        break
    fi
    sleep 5
done
```



#### 16、nc

```shell
#!/bin/bash
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }

jarName=$1
#获取进程ID
jarPid=$(jps |grep ${jarName}|awk '{print $1}')

#获取进程ID对应的服务端口号
jarPort=$(ss -tunlp|grep ${jarPid}|grep tcp|awk '{print $5}'|awk -F ":" '{print $NF}')

#获取内网IP
ip=$(ip a|grep inet|grep -v 127.0.0.1|egrep -v "inet6|br-|docker"|awk '{print $2}'|awk -F '/' '{print $1}')
while true;do
  nc  -vz ${ip} ${jarPort}
  if [ $? -eq 0 ];then
        echoRed "-------------> successed <--------------"
        break
  fi
  sleep 3
done
```



#### 17、[shell脚本条件判断](https://zahui.fan/posts/le2ugemu/)

|| 和 &&

|| 前面执行不通过才执行后面的，也就是或， && 是与，前面执行通过会接着执行后面的

```
[ -d /tmp/111 ] || { mkdir /tmp/111; cd /tmp/111; pwd; }

# 三元判断
[ -e .env.exampl ] && echo "文件存在" || echo "文件不存在"
```

```
NAMESPACE=xxxgrayxxx
if [[ $NAMESPACE =~ prod ]] || [[ $NAMESPACE =~ gray ]]
then
    echo "是prod或gray"
else
    echo "不重要的环境，随便造"
fi
```



#### 18、随机字符

```
rand=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4)
```



#### 19、 基本路径和目录路径

```
SRC="/path/to/foo.cpp"
BASEPATH=${SRC##*/}   
echo $BASEPATH  # => "foo.cpp"

DIRPATH=${SRC%$BASEPATH}
echo $DIRPATH   # => "/path/to/"
```

#### 20、Bash 条件句

##### 1、整数条件

| `[[ NUM -eq NUM ]]` | 等于 Equal                     |
| ------------------- | ------------------------------ |
| `[[ NUM -ne NUM ]]` | 不等于 Not equal               |
| `[[ NUM -lt NUM ]]` | 小于 Less than                 |
| `[[ NUM -le NUM ]]` | 小于等于 Less than or equal    |
| `[[ NUM -gt NUM ]]` | 大于 Greater than              |
| `[[ NUM -ge NUM ]]` | 大于等于 Greater than or equal |
| `(( NUM < NUM ))`   | 小于                           |
| `(( NUM <= NUM ))`  | 小于或等于                     |
| `(( NUM > NUM ))`   | 比...更大                      |
| `(( NUM >= NUM ))`  | 大于等于                       |

##### 2、字符串条件

| `[[ -z STR ]]`     | 空字符串       |
| ------------------ | -------------- |
| `[[ -n STR ]]`     | 非空字符串     |
| `[[ STR == STR ]]` | 相等           |
| `[[ STR = STR ]]`  | 相等(同上)     |
| `[[ STR < STR ]]`  | 小于 *(ASCII)* |
| `[[ STR > STR ]]`  | 大于 *(ASCII)* |
| `[[ STR != STR ]]` | 不相等         |
| `[[ STR =~ STR ]]` | 正则表达式     |

##### 3、文件条件

| `[[ -e FILE ]]`   | 存在          |
| ----------------- | ------------- |
| `[[ -d FILE ]]`   | 目录          |
| `[[ -f FILE ]]`   | 文件          |
| `[[ -h FILE ]]`   | 符号链接      |
| `[[ -s FILE ]]`   | 大小 > 0 字节 |
| `[[ -r FILE ]]`   | 可读          |
| `[[ -w FILE ]]`   | 可写          |
| `[[ -x FILE ]]`   | 可执行文件    |
| `[[ f1 -nt f2 ]]` | f1 比 f2 新   |
| `[[ f1 -ot f2 ]]` | f2 比 f1 新   |
| `[[ f1 -ef f2 ]]` | 相同的文件    |

| `[[ -o noclobber ]]` | 如果启用 OPTION |
| -------------------- | --------------- |
| `[[ ! EXPR ]]`       | 不是 Not        |
| `[[ X && Y ]]`       | 和 And          |
| `[[ X || Y ]]`       | 或者 Or         |

#### 21 printf 屏幕输出



```shell
printf "\n> \033[32m恭喜您，安装成功！\033[0m 请收藏这个页面，在您遇到问题的时候可以查看文档：\n${doc_url}\n\n"
```

#### 22 case使用



https://blog.csdn.net/weixin_43357497/article/details/107774070

```shell
#!/usr/bin/bash
#system manage
#v1.0 tianyum 2020-8-20

menu() {        #函数写法 
cat <<-EOF
################################################
#       h. help                                #
#       f. dis partition                       #
#       d. filesystem mount                    #
#       m. memtem load                         #
#       u. system load                         #
#       q. exit                                #
################################################
EOF
}
menu
while true

do
echo -en  "\e[1;33m Please input [h for help]: \e[0m "
read action
        case "$action" in
        h)
                clear
                menu
                ;;
        f)
                fdisk -l
                ;;
        d)
                df -Th
                ;;
        m)
                free -m
                ;;
        u)
                uptime
                ;;
        q)
                #exit
                break
                ;;
        " ")                                                        ‘’ ''   //表示空值
                ;;
        *)
                echo "error "

        esac
done
        echo "finsih......"

```

**case嵌套结构**

```
case $office in
"1"）
   case $RegionalMgr in
      "Bob"）
         echo "Hello,Bob"
       ;;
    esac
 ;;
esac
```

