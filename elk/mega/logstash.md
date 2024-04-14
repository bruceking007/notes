

#### 1、logstah配置文件

```yaml
#kafka中读取日志数据
input {                         #数据源端
        kafka {                         #类型为kafka
                bootstrap_servers => ["10.10.0.220:9092,10.10.0.250:9092,10.10.0.134:9092"]
                topics => ["dm-pro","cfox-pro","bball-pro","jumppage-pro"]                      #要读取那些kafka topics
                codec => "json"                                                                         #处理json格式的数据
                #auto_offset_reset => "latest"                                          #只消费最新的kafka数据
                consumer_threads => 1                                           # 增加consumer的并行消费线程数
        }
}

filter {
        if "java" in [tags] {           #如果log_topic字段为dm-pro
            grok {                              #解析格式
                match => {
                        "message" => "(?<log_time>[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}) \[(?<线程名称>[^\s]{0,})\] (?<日志等级>\w+) (?<类名称>[^\s]{0,}) (?<日志详情>[\W\w]+)"

                }
            }

            date {
                match => ["log_time", "yyyy-MM-dd HH:mm:ss,SSS", "ISO8601"]
                target => "@timestamp"
            }

            mutate {                    #修改数据
                 remove_field => ["_index","_id","_type","_version","_score","referer","agent","log_time"]                      #删除没用的字段
            }  
        }


      if "nginx" in [tags] and "access" in [tags]{

          if "iPhone;" in [http_user_agent] {
                  mutate { add_field => { "deviceOS" => "iphone OS" } }
          }else if "Android" in [http_user_agent] {
                  mutate { add_field => { "deviceOS" => "Android" } }
          }else if "Windows" in [http_user_agent] {
                  mutate { add_field => { "deviceOS" => "Windows" } }
          }else if "Macintosh;" in [http_user_agent] {
                  mutate { add_field => { "deviceOS" => "Mac OS" } }
          }else {
                  mutate { add_field => { "deviceOS" => "unkown" } }
          }  

          geoip {
                source => [realip]
                target => "geoip"
                database => "/etc/logstash/GeoIP/GeoLite2-City.mmdb"
                #add_field => [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
                #add_field => [ "[geoip][coordinates]", "%{[geoip][latitude]}" ]
          }

           date {
                match => ["time_local", "dd/MMM/yyyy:HH:mm:ss Z"]
                target => "@timestamp"
           }

            mutate {
                remove_field => ["_index","_id","_type","_version","_score","referer","agent"]
                #convert => [ "[geoip][coordinates]", "float"]
                convert => ["upstream_time", "float"]
                convert => ["request_time", "float"]
                convert => ["body_bytes_sent","integer"]
            }
      }
}

#数据处理后存储es集群
output {                                #目标端
        if [fields][logtype] == "nginx" {
        elasticsearch {
            action => "index"                           #类型为索引
            hosts => ["10.10.0.198:9200","10.10.0.57:9200","10.10.0.48:9200"]                   #es集群地址
            user => "admin"
            password => "qPcKy6wVYZu88hZF"
            index => "logstash-%{[fields][project]}-%{[fields][env]}-%{[fields][logtype]}-%{[fields][appname]}-%{+YYYY.MM.dd}"                   #存储到es集群的哪个索引里
            codec => "json"                                             #处理json格式的解析
        } 
       }
       else {
        elasticsearch {
            action => "index"                           #类型为索引
            hosts => ["10.10.0.198:9200","10.10.0.57:9200","10.10.0.48:9200"]                   #es集群地址
            user => "admin"
            password => "qPcKy6wVYZu88hZF"
            index => "%{[fields][project]}-%{[fields][env]}-%{[fields][logtype]}-%{[fields][appname]}-%{+YYYY.MM.dd}"
            codec => "json"                                             #处理json格式的解析
        } 
       }
}
```

#### 2、守护进程

logstash.ini

```
[program:logstash]
user=root
directory=/etc/logstash/conf.d

#command=/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/kafka_to_es.conf
command=/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d

autostart=true
autorestart=false
startsecs=1
stdout_logfile=/tmp/logstash.log
redirect_stderr = true
stdout_logfile_maxbytes = 20MB
stdout_logfile_backups = 5
```

supervisorctl

```
# supervisorctl status
logstash                         RUNNING   pid 6453, uptime 2:09:06
```



#### 3、安装 multiline 插件

multiline 不是 logstash 自带的，需要单独进行安装。我们的环境是没有外网的，所以需要进行离线安装。

```
/usr/share/logstash/bin
./logstash-plugin install logstash-filter-multiline
```

![image-20230818180155432](/Users/mac-fl-036/Desktop/all-v2/meta/ELK/assets/image-20230818180155432.png)
