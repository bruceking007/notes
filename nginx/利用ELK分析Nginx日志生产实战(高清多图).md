# 利用ELK分析Nginx日志生产实战(高清多图)



**一、服务介绍**

**1.1、ELK**

ELK是三个开源软件的缩写，分别表示：Elasticsearch , Logstash, Kibana , 它们都是开源软件。新增了一个FileBeat，它是一个轻量级的日志收集处理工具(Agent)，Filebeat占用资源少，适合于在各个服务器上搜集日志后传输给Logstash，官方也推荐此工具。

Elasticsearch是个开源分布式搜索引擎，提供搜集、分析、存储数据三大功能。它的特点有：分布式，零配置，自动发现，索引自动分片，索引副本机制，restful风格接口，多数据源，自动搜索负载等。

Logstash 主要是用来日志的搜集、分析、过滤日志的工具，支持大量的数据获取方式。一般工作方式为c/s架构，client端安装在需要收集日志的主机上，server端负责将收到的各节点日志进行过滤、修改等操作在一并发往elasticsearch上去。

Kibana 也是一个开源和免费的工具，Kibana可以为 Logstash 和ElasticSearch 提供的日志分析友好的 Web 界面，可以帮助汇总、分析和搜索重要数据日志。

***\*1.2、\**Nginx**

Nginx("engine x") 是一个高性能的HTTP和反向代理服务器，也是一个IMAP/POP3/SMTP代理服务器。 Nginx 是由 Igor Sysoev 为俄罗斯访问量第二的 Rambler.ru 站点开发的，第一个公开版本0.1.0发布于2004年10月4日。其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、示例配置文件和低系统资源的消耗而闻名。Nginx是一款轻量级的Web服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器，并在一个BSD-like 协议下发行。由俄罗斯的程序设计师Igor Sysoev所开发，供俄国大型的入口网站及搜索引擎Rambler（俄文：Рамблер）使用。其特点是占有内存少，并发能力强，事实上nginx的并发能力确实在同类型的网页服务器中表现较好，中国大陆使用nginx网站用户有：新浪、网易、腾讯等。

本文中前端使用了nginx的反向代理功能，并使用了nginx的HTTP功能。

***\*1.3、\**Kafka**

Kafka是由Apache软件基金会开发的一个开源流处理平台，由Scala和Java编写。Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理消费者规模的网站中的所有动作流数据。这种动作（网页浏览，搜索和其他用户的行动）是在现代网络上的许多社会功能的一个关键因素。 这些数据通常是由于吞吐量的要求而通过处理日志和日志聚合来解决。 对于像Hadoop一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。Kafka的目的是通过Hadoop的并行加载机制来统一线上和离线的消息处理，也是为了通过集群来提供实时的消息。

**二、架构要求**

***\*2.1、\**架构描述**

使用filebeat收集nginx日志，输出到kafka;logstash从kafka中消费日志，通过grok进行数据格式化，输出到elasticsearch中,kibana从elasticsearch中获取日志，进行过滤出图.

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XTMGDqjviaUQF1T8LA1CLZwGrqYXB6X8icTZKHf69uyjdfM4icxLV1LXGw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

***\*2.2、\**系统版本**

```
CentOS Linux release 7.2.1511 (Core)
3.10.0-514.26.2.el7.x86_64
```

 **2.3、\**软件版本\****

```
jdk1.8.0_144
nginx-1.12.2
filebeat-6.3.2
awurstmeister/kafka(docker image)
logstash-6.5.4
elasticsearch-6.4.0
kibana-6.4.0
```



**三、linux****系统环境配置与优化**

```
#查看服务器硬件信息
dmidecode|grep "Product Name"

#查看CPU型号
grep name /proc/cpuinfo

#查看CPU个数
grep "physical id" /proc/cpuinfo

#查看内存大小
grep MemTotal /proc/meminfo
```

**
**

 **四、系统初始化**

**4.1、关闭防火墙**

```
systemctl stop filewalld
```

**4.2、关闭selinux**

```
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

**4.3、添加普通账户**

```
useradd elsearch
echo "******"|passwd --stdin elsearch
```

**4.4、配置yum源**

```
cat /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-$releasever
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever
enabled=1
failovermethod=priority
baseurl=http://mirrors.cloud.aliyuncs.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.cloud.aliyuncs.com/centos/RPM-GPG-KEY-CentOS-7
```

**4.5、清理开机自启动服务**

```
for i in `chkconfig --list|grep 3:on |awk '{print $1}'`;do chkconfig$i off;done
for i in crond network rsyslog sshd;do chkconfig --level 3 $ion;done
chkconfig --list|grep 3:on
```

**4.6、服务器时间同步**

```
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com > /dev/null2>&1' >>/var/spool/cron/root
```

**4.7、加大文件描述符**

```
echo '* - nofile 65535' >> /etc/security/limits.conf
tail -1 /etc/security/limits.conf
#重新登陆后生效(无需重启)
ulimit -n(重新登陆后查看)
```

 **4.8、内核参数调优(可不操作)**

```
\cp /etc/sysctl.conf /etc/sysctl.conf.bak
cat>>/etc/sysctl.conf<<EOF
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout=1
net.ipv4.tcp_keepalive_time=1200
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p
```

 

**五、部署开始**

**5.1、更改nginx日****志输出格式**

**5.1.1、定义日志格式**

```
cat /etc/nginx/nginx.conf
log_format main '$remote_addr - $remote_user [$time_local]"$request" '
'$status$body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x_forwarded_for"';
```

**5.1.2、加载日志格式到对应域名配置中**

```
cat /etc/nginx/conf.d/vhost/api.mingongge.com.cn.conf
server {
listen 80;
server_name  newtest-msp-api.mingongge.com.cn;
access_log   /var/log/nginx/api.mingongge.com.cn.log main;
}
```

**5.1.3、reload生效**

```
nginx -s reload
```

**5.1.4、清空原输出文件，并查看输出的日志格式**

```
:> /var/log/nginx/api.mingongge.com.cn.log
tailf /var/log/nginx/api.mingongger.com.cn.log
1xx.2xx.72.175 - - [18/Mar/2019:13:51:17 +0800] "GET/user/fund/113 HTTP/1.1" 200 673 "-" "Mozilla/5.0 (WindowsNT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) sun/1.5.6 Chrome/69.0.3497.106Electron/4.0.3 Safari/537.36" "-"
```

**5.2、配置kafka**

测试环境使用docker起的kafka，kafka部署掠过,以下任选一种

**5.2.1、方法一 创建kafka topic**

```
./kafka-topics.sh --create --topic nginxlog --replication-factor 1--partitions 1 --zookeeper localhost:2181
```

**5.2.2、方法二**

```
auto.create.topics.enable=true
```

开启kafka自动创建topic配置

**5.2.3、filebeat部署完成后确认kafka topic中有数据**

```
./kafka-console-consumer.sh --bootstrap-server 192.168.0.53:9091--from-beginning --topic nginxlog
```

输出如下

```
{"@timestamp":"2019-03-14T07:16:50.140Z","@metadata":{"beat":"filebeat","type":"doc","version":"6.3.2","topic":"nginxlog"},"fields":{"log_topics":"nginxlog"},"beat":{"version":"6.3.2","name":"test-kafka-web","hostname":"test-kafka-web"},"host":{"name":"test-kafka-web"},"source":"/var/log/nginx/newtest-msp-api.mingongge.com.cn-80.log","offset":114942,"message":"116.226.72.175- - [14/Mar/2019:15:16:49 +0800] newtest-msp-api.mingongge.com.cn POST\"/upstream/page\" \"-\" 200 6314\"http://newtest-msp-crm.mingongge.com.cn/\" 200 192.168.0.49:60070.024 0.024 \"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36(KHTML, like Gecko) Chrome/70.0.3538.67 Safari/537.36\"\"-\""}
Processed a total of 7516 messages
```

测试环境中kafka地址为

- 

```
192.168.0.53:9091
```

 **5.3、配置filebeat收集nginx日志**

**5.3.1、安装filebeat**

```
cd /opt/ && wget http://download.mingongge.com.cn/download/software/filebeat-6.3.2-x86_64.rpm
yum localinstall filebeat-6.3.2-x86_64.rpm -y
```

**5.3.2、编辑配置文件**

```
cat /etc/filebeat/filebeat.yml

filebeat.prospectors:
- input_type: log
enabled: true
paths:
- /var/log/nginx/api.mingongge.com.cn.log#收集日志路径
fields:
log_topics: nginxlog #kafka中topic名称
json.keys_under_root: true
json.overwrite_keys: true

output.kafka:
enabled: true
hosts:["192.168.0.53:9091"] #kafka地址
topic:'%{[fields][log_topics]}' #kafka中topic名称
partition.round_robin:
reachable_only: false
compression: gzip
max_message_bytes: 1000000
required_acks: 1
```

**5.3.3、启动filebeat& 开机启动**

```
systemctl start filebeat
systemctl enable filebeat
```

**5.4、配置logstash**

**5.4.1 编辑配置**

```
cat /usr/local/logstash/config/nginx.conf
input {
kafka {
type =>"nginxlog"
topics =>["nginxlog"]
bootstrap_servers=> ["192.168.0.53:9091"]
group_id =>"nginxlog"
auto_offset_reset=> latest
codec =>"json"
}
}

filter {
if [type] == "nginxlog"{
grok {
match => {"message" => "%{COMBINEDAPACHELOG}" }
remove_field =>"message"
}
date {
match => ["timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
}
geoip {
source =>"clientip"
target =>"geoip"
database =>"/usr/local/logstash/config/GeoLite2-City.mmdb"
add_field => ["[geoip][coordinates]", "%{[geoip][longitude]}" ] #添加字段coordinates，值为经度
add_field => ["[geoip][coordinates]", "%{[geoip][latitude]}" ] #添加字段coordinates，值为纬度
}
mutate {
convert => ["[geoip][coordinates]", "float"]
}
useragent {
source =>"agent"
target =>"userAgent"
}
}
}
output {
if [type] == 'nginxlog' {
elasticsearch {
hosts =>["http://192.168.0.48:9200"]
index =>"logstash-nginxlog-%{+YYYY.MM.dd}"
}
stdout {codec =>rubydebug}
}
}
```

**5.4.2、使用配置文件启动logstash服务，观察输出**

```
/usr/local/logstash/bin/logstash -f nginx.conf

{
"httpversion"=> "1.1",
"verb" =>"GET",
"auth"=> "-",
"@timestamp"=> 2019-03-18T06:41:27.000Z,
"type"=> "nginxlog",
"json"=> {},
"source"=> "/var/log/nginx/newtest-msp-api.mingongge.com.cn-80.log",
"fields" =>{
"log_topics"=> "nginxlog"
},
"response"=> "200",
"offset"=> 957434,
"host"=> {
"name" =>"test-kafka-web"
},
"beat"=> {
"hostname"=> "test-kafka-web",
"version"=> "6.3.2",
"name"=> "test-kafka-web"
},
"bytes"=> "673",
"request"=> "/user/fund/113",
"timestamp"=> "18/Mar/2019:14:41:27 +0800",
"referrer"=> "\"-\"",
"userAgent"=> {
"os"=> "Windows",
"major" => "4",
"patch"=> "3",
"build"=> "",
"minor"=> "0",
"os_name"=> "Windows",
"device"=> "Other",
"name"=> "Electron"
},
"geoip"=> {
"ip" => "1xx.2xx.72.175",
"country_name" => "China",
"coordinates" => [
[0] 121.4012,
[1] 31.0449
],
"region_name" => "Shanghai",
"location" => {
"lat"=> 31.0449,
"lon"=> 121.4012
},
"continent_code" => "AS",
"timezone" => "Asia/Shanghai",
"longitude" => 121.4012,
"city_name" => "Shanghai",
"country_code2" => "CN",
"region_code" => "SH",
"latitude" => 31.0449,
"country_code3" => "CN"
},
"@version"=> "1",
"clientip"=> "1xx.2xx.72.175",
"ident"=> "-",
"agent"=> "\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36(KHTML, like Gecko) sun/1.5.6 Chrome/69.0.3497.106 Electron/4.0.3Safari/537.36\""
}
```

**5.4.3、后台启动logstash**

确认出现以上输出后，将logstash分离出当前shell,并放在后台运行

```
nohup /usr/local/logstash/bin/logstash -f nginx.conf &>/dev/null &
```

**5.5、kibana配置**

**5.5.1、修改kibana配置**

```
/usr/local/kibana-6.5.4-linux-x86_64/config/kibana.yml #增加高德地图
tilemap.url:'http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}'
```

**5.5.2、创建Index Pattern**

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XvzknzbN4XGDCrRSF8zWgJkYuV6N76FFy0ZFfu3L2TMZZywDDa39ib4A/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0Xib2ibWfnhNexs3bI3POS1yJLytxxpI4RyFKXyF3FRVJR3e64FmSiaRCtw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.3、IP访问TOP5**

选择柱形图

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XlXJSmJF5HxiaMg6iadSp2Wslw5Np0XRJtsrJZKiacvkh9E3DD3MibBniaCQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

添加X轴，以geoip.ip为order by字段

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XZquovTVwlb1ngiabQOicfxx20MV9KaYKSjJqpcbDKIxLsLatUbN0SehQ/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.4 、PV**

选择metric

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XHzIXnSYt1rCzyv8bQwJZI268WozdO6lMNNDsVWgWcflt6gvZjNhkVQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

默认统计总日志条数,即为PV数

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XkuaU3upbNPVokOentkiaXLaOVQ3vibJWwIibCQSrNBOu0G0wHgh14803A/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1) **5.5.5、全球访问地图**

选择map

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XE7Rsiak6ic1YhMeB7oWl2YXJoHD0ygPwP1mY8zicgibzFRQ4Hn2pTFZahg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

Field选择geoip.location

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XcFubK1ZicQfL8o5nGktFIzR55IrCRib1TVGL3QtjJxCj4LveiaNS0qGgQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

选择添加高德地图

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XKKfTAlAFFicJ7a7rKGjgSJFouDJR3DA8DDkMZ8AcVxFtfo8BNzXmajA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1) **5.5.6、实时流量**

选择线条图

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XSsm254Gib2Hcoic4nibwg6uxRYmyklxqicibHZs6q1UbBPajEVAh1ib0zfeg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0X1PgA2sic0Q7jH2wHSN9CUDj6eG0By9osth4pN8t6pXjAt2flv9R6rWQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.7、操作系统**

选择饼图

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XdiaezqfmFmicdRNB9oiaib5bXHibygWzzsDCZXjE9rQbrwCn1PhVSJoobcg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0Xv3huOlYAm2QFvLnaribWdQeDIuyXTSK8dmiaxGJWteG0d6yticVmXDBOQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.8、登陆次数**

过滤login关键字,并做count统计

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0XbvNTjzfDJrxMtKe4kOyhWhib6vkwXTIrCGefkLeQAuLico1nqTZEaMicg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.9、访问地区**

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0X3oEibmJonjsiaaFvyGP21SyvTHQQf1tYia727ib3B9keeWNz3hBMO7Aeww/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

**5.5.10、Dashboard展示**

- IP访问Top5:每日客户端IP请求数最多的前五个(可分析出攻击者IP)
- PV:每日页面访问量
- 全球访问图:直观的展示用户来自哪个国家哪个地区
- 实时流量:根据@timestamp字段来展示单位时间的请求数(可根据异常峰值判断是否遭遇攻击)
- 操作系统:展示客户端所用设备所占比重
- 登陆次数:通过过滤request中login的访问记录,粗略估算出进行过登陆的次数
- 访问地区:展示访问量最多的国家或地区
- 需展示其他指标，可进行自由发挥

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPo8ibHCezOY2TT6zEQgWTb0X5PleCJxia50htKDVHxs4PKJK2ojNKS0T1Pjn7xiaQc7S0ZVMQL3RiaDCA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

 

**- MORE | 往期精彩文章 -**

- [逼格高又实用的 Linux 命令，一定要懂！](http://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247488852&idx=1&sn=8c002f92ce3b61bd7e611dd8ddeff680&chksm=e91b7048de6cf95eb9c0f9e19a5b30cd2bc80dc7a39c8037a71411bfbf63daa56803a4a0eedb&scene=21#wechat_redirect)
- [一文详解 LVS、Nginx 及 HAProxy 工作原理](http://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247488822&idx=1&sn=0626d7c8d21adb82e04f20cbf474d5fb&chksm=e91b702ade6cf93cd151649c89c1ea14c94dca04f5b72478a67fe8e2565a33d997a84b0d0e23&scene=21#wechat_redirect)
- [老司机告诉你：正规的运维工作是什么的?](http://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247488821&idx=2&sn=1c53372eb6553583d95b221f78fa540c&chksm=e91b7029de6cf93f2725122f3e109288c1117aac0754f97ab77f976871f3713880da7a78a76c&scene=21#wechat_redirect)
- [别装，你是干什么的，一句话就能说明！](http://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247488801&idx=1&sn=5036d9559fe97f0b391b9c135429f038&chksm=e91b703dde6cf92b37d049aa21b5db066d1bf5652b85e61bda0430b515ee08d7a6cd3540896e&scene=21#wechat_redirect)
- [哪来那么多开挂的人生？都是骗人的....](http://mp.weixin.qq.com/s?__biz=MzI0MDQ4MTM5NQ==&mid=2247488801&idx=2&sn=172c974ba5d9edeb81627588fe44d165&chksm=e91b703dde6cf92b6b4b92fdd42b4b5929eccbcf291a5db1a32f7603e3d014a9e3e979eaac75&scene=21#wechat_redirect)



**如果你喜欢本文**

**请长按二维码关注****民工哥技术之路**

![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPria1cKL66Pc1sJlVK9hzIbQzpsC28YMFgQosWDibUEXGL9skdseEgPSsAke5lsicGFd5ibT0WIlkb7pQ/640?wxfrom=5&wx_lazy=1&wx_co=1)

**转发朋友圈，是对我最大的支持。**

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/tuSaKc6SfPoHDJbPz3g7Kic6hdYnbBc4ZbJibyMQdYLkCn94rGc9DibFv4PMvhCFOfkuSKZRR3MeJo6uuUWz5jx5Q/640?wxfrom=5&wx_lazy=1&wx_co=1)

**扫码加群交流**

**点击【****阅读原文****】公众号所有的精华都在这**

***\**\*觉得好看，请点这里↓\*\*\*\*\*\*\*\*↓\*\*\*\*\*\*\*\*\*\*\*\*↓\*\*\*\*\*\**\***

收录于合集 #Nginx

 69个

上一篇请务必收藏！Nginx 五大常见应用场景下一篇NginxWebUI 1.8.0版本发布

文章已于2019-03-28修改

[阅读原文](javascript:;)

喜欢此内容的人还喜欢

又一国产桌面操作系统震撼发布！支持 Linux、Windows、安卓三大生态

...

民工哥技术之路

不喜欢

不看的原因

确定

- 内容质量低
-  

- 不看此公众号

![img](https://mp.weixin.qq.com/mp/qrcode?scene=10000004&size=102&__biz=MzI0MDQ4MTM5NQ==&mid=2247488853&idx=1&sn=82a3d04d81d254bbb445fd10ad215dd9&send_time=)

微信扫一扫
关注该公众号