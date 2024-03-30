![Nginx基础](https://static.iots.vip/2017/01/201701317210_1680.png)

### 1 四层代理stram

##### (1)、编辑nginx.conf

stream模块和http模块是并列级别的，所以stream要写在http{}外边

```
stream {

    log_format proxy '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /var/log/nginx/tcp-access.log proxy ;
    open_log_file_cache off;
    include /etc/nginx/conf.d/*.stream;
}
```

![image-20230805142228015](assets/image-20230805142228015.png)

##### (2) 添加.stram文件

```
#proxy mysql-1
server {
    listen 8089;
    proxy_pass 192.168.0.207:3306;
}

#proxy mysql-2
server {
    listen 8090;
    proxy_pass 192.168.0.166:3306;
}
```

![image-20230805142327887](assets/image-20230805142327887.png)

https://www.cnblogs.com/pxyblog/p/17553205.html





### 2 location优先级

（1）首先精确匹配:=

（2）其次前缀匹配:^~

（3）其次是按文件中顺序的正则匹配:或*

（4）然后匹配不带任何修饰的前缀匹配

（5）最后是交给/通用匹配

总结：
（1）优先级总结：（location=完整路径）>（location ^~ 路径）>（location~,~*正则顺序）>（location不分起始路径）>（location /）
（2）location匹配：
首先看优先级：精确（=）>前缀（^~）>正则（~,~*）>一般>通用（/）
优先级相同：正则看上下顺序，上面的优先，一般匹配看长度，最长匹配的优先
精确，前缀，正则，一般都没有匹配到，最后再看通用匹配，一般匹配





### 3 统计pv uv

##### 普通日志格式

```
#PV
grep SOM09HT *.json|grep '14/Aug'|wc -l
grep SOM09HT *.json|grep '21/Aug'|wc -l

#UV
grep SOM09HT *.json|grep '14/Aug'|awk '{print $1}'|awk -F : '{print $2}'|sort|uniq -c|sort -nr|wc -l
grep SOM09HT *.json|grep '21/Aug'|awk '{print $1}'|awk -F : '{print $2}'|sort|uniq -c|sort -nr|wc -l
```



##### json格式日志

```
#PV
grep '26/Aug/2023:14' *.json|grep STLLA036|wc -l

#UV
grep '26/Aug/2023:14' *.json|grep STLLA036| awk -F '"' '{print $12}'|sort|uniq -c|sort -nr|wc -l
```



### 4 日志格式

```
   #1、获取真实的用户ip
   map $http_x_forwarded_for  $clientRealIp {
     "" $remote_addr;
     ~^(?P<firstAddr>[0-9\.]+),?.*$  $firstAddr;
    }
    
    server_tokens off; #隐藏版本

    log_format main '$remote_addr - $remote_user [$time_local] "$request $scheme://$host$request_uri" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent"' ' $connection $upstream_addr '
                    'ups_time $upstream_response_time req_time $request_time' 
                    ' $request_body' ' $clientRealIp';
```



### 5 Nginx报Too Many Open Files总结

[Nginx报Too Many Open Files总结](https://blog.csdn.net/u011635437/article/details/113620068)

[systemd service 配置 ulimit 限制](https://halysl.github.io/2020/11/18/systemd-service%E9%85%8D%E7%BD%AEulimit%E9%99%90%E5%88%B6/)

[nginx服务器优化](https://bg6cq.github.io/ITTS/app/nginx/nginx-opt/)

[Linux配置调优：最大打开文件描述符个数](http://www.ideabuffer.cn/2016/11/20/Linux%E9%85%8D%E7%BD%AE%E8%B0%83%E4%BC%98%EF%BC%9A%E6%9C%80%E5%A4%A7%E6%89%93%E5%BC%80%E6%96%87%E4%BB%B6%E6%8F%8F%E8%BF%B0%E7%AC%A6%E4%B8%AA%E6%95%B0/)



##### 1、如果想查看当前进程打开了多少个文件，可以执行如下命令查看：

```shell
lsof -n | awk '{print $2}' | sort | uniq -c | sort -nr | more

执行后可以看到，第一列是打开的文件描述符数量，第二列是进程id。
```

##### 2、检查当前nginx服务master 进程 和 worker 进程的文件句柄限制

（1）在 Nginx 运行时，检查当前 master 进程的限制：

```shell
#cat /proc/$(cat /var/run/nginx.pid)/limits|grep open.files
Max open files            1024                 4096                 files
```

（2）检查 worker 进程：

```shell
#ps --ppid $(cat /var/run/nginx.pid) -o %p|sed '1d'|xargs -I{} cat /proc/{}/limits|grep open.files
Max open files            1024                 4096                 files     
Max open files            1024                 4096                 files     
Max open files            1024                 4096                 files     
Max open files            1024                 4096                 files 
```

系统每打开一个文件，都会占用一个文件描述符，而系统打开文件描述符是有上限的。在centos下默认值一般为1024，可以通过命令查看：

```shell
# ulimit -n
1024
# ulimit -a
open files                      (-n) 1024
```

##### 3、首先确定下系统内核允许文件打开数量的上限(内核级别的，默认值为95086)

```shell
# sysctl -n -e fs.file-max
102400

调整方法：
# vi /etc/sysctl.conf
fs.file-max = 655350
# sysctl -p
其他：比如限制fs.file-max最多只能使用内存的10%
# grep -r MemTotal /proc/meminfo | awk '{printf("%d\n",$2/10)}' 
```

##### 4、修改/etc/security/limits.conf文件，设置打开的文件数量上限。(系统级别的)

```shell
# vim /etc/security/limits.conf
*      soft    nofile  655350
*      hard    nofile  655350
*      soft    nproc   655350
*      hard    nproc   655350
```

其中第一行soft表示所有用户打开文件的数量限制为65535，如果超过这个数字则提示警告信息，但是依然可以打开文件。
第二行hard表示最大的打开文件数量不能超过65535，如果超过这个数字，则无法打开文件。
这里也可以针对具体的用户进行相应的设定。例如针对nginx用户进行设定：



soft：软控制，到达设定值后，操作系统不会采取措施，只是发提醒
hard：硬控制，到达设定值后，操作系统会采取机制对当前进行进行限制，这个时候请求就会受到影响
root：这里代表root用户（系统全局性修改）
*：代表全局，即所有用户都受此限制（用户局部性修改）
nofile：指限制的是文件数的配置项。后面的数字即设定的值，一般设置10000左右

```shell
nginx soft nofile 655350
nginx hard nofile 655350
```

##### 5、修改/etc/profile文件,设置打开的文件数量上限

```shell
echo "ulimit -SHn 655350" >> /etc/profile
source /etc/profile
```

修改完这里之后，退出shell重新登录下机器查看

```shell
# ulimit -n
655350
# ulimit -a
open files                      (-n) 655350
```

注意：
1）、nofile代表文件句柄数量；soft nofile的值不能超过hard nofile的值
2）、如果修改完成，查看ulimit -n与ulimit -a显示的结果依然是1024，排查如下：
（1）需要查看/etc/profile配置是否有设定ulimit相关配置，/etc/profile环境变量里的参数配置最优先，会覆盖limits.conf 里的配置
（2）在Centos7系统中，使用Systemd替代了之前的SysV。/etc/security/limits.conf文件的配置作用域缩小了。/etc/security/limits.conf的配置，只适用于通过PAM认证登录用户的资源限制，它对systemd的service的资源限制不生效。因此登录用户的限制，通过/etc/security/limits.conf与/etc/security/limits.d下的文件设置即可。
对于systemd service的资源设置，则需修改全局配置，全局配置文件放在/etc/systemd/system.conf和/etc/systemd/user.conf，同时也会加载两个对应目录中的所有.conf文件/etc/systemd/system.conf.d/.conf和/etc/systemd/user.conf.d/.conf。system.conf是系统实例使用的，user.conf是用户实例使用的。

```shell
# vi /etc/systemd/system.conf (原文如此，跳过)
DefaultLimitNOFILE=655350
DefaultLimitNPROC=655350
```

3）、如果上述的方法均无法解决，可以直接将 ulimit -SHn 655350 配置到nginx启动脚本中（注意按第4点在nginx.conf配置文件中增加打开文件数量上限后操作。）

```shell
# vi /etc/init.d/nginx
ulimit  -SHn  655350
或是
# vi /usr/lib/systemd/system/nginx.service
[Service]
LimitCORE=infinity
LimitNOFILE=655350
LimitNPROC=655350

重新加载系统服务
systemctl daemon-reload
systemctl restart nginx
systemctl status nginx
```

最后确认nginx主进程与work进程的文件打开数

```shell
cat /proc/$(cat /var/run/nginx.pid)/limits|grep open.files
ps --ppid $(cat /var/run/nginx.pid) -o %p|sed '1d'|xargs -I{} cat /proc/{}/limits|grep open.files
```

##### 6、修改nginx配置文件，设置打开文件数量上限。（程序级别的）

在nginx.conf配置文件中增加如下设置：worker_rlimit_nofile 655350 (进程的最大打开文件数限制)

```shell
# vi nginx.conf
user  nginx;
worker_processes  auto;
worker_rlimit_nofile 655350;
```

该参数表示每个工作进程可以打开的文件数量。作用域和worker_processes一样。
修改了nginx文件，需要reload一下。





### 6 nginx json日志格式

```json
# json日志格式
log_format json_analytics escape=json '{'
                            '"msec": "$msec", ' # request unixtime in seconds with a milliseconds resolution
                            '"connection": "$connection", ' # connection serial number
                            '"connection_requests": "$connection_requests", ' # number of requests made in connection
                    '"pid": "$pid", ' # process pid
                    '"request_id": "$request_id", ' # the unique request id
                    '"request_length": "$request_length", ' # request length (including headers and body)
                    '"remote_addr": "$remote_addr", ' # client IP
                    '"remote_user": "$remote_user", ' # client HTTP username
                    '"remote_port": "$remote_port", ' # client port
                    '"time_local": "$time_local", '
                    '"time_iso8601": "$time_iso8601", ' # local time in the ISO 8601 standard format
                    '"request": "$request", ' # full path no arguments if the request
                    '"request_uri": "$request_uri", ' # full path and arguments if the request
                    '"args": "$args", ' # args
                    '"status": "$status", ' # response status code
                    '"body_bytes_sent": "$body_bytes_sent", ' # the number of body bytes exclude headers sent to a client
                    '"bytes_sent": "$bytes_sent", ' # the number of bytes sent to a client
                    '"http_referer": "$http_referer", ' # HTTP referer
                    '"http_user_agent": "$http_user_agent", ' # user agent
                    '"http_x_forwarded_for": "$http_x_forwarded_for", ' # http_x_forwarded_for
                    '"http_host": "$http_host", ' # the request Host: header
                    '"server_name": "$server_name", ' # the name of the vhost serving the request
                    '"request_time": "$request_time", ' # request processing time in seconds with msec resolution
                    '"upstream": "$upstream_addr", ' # upstream backend server for proxied requests
                    '"upstream_connect_time": "$upstream_connect_time", ' # upstream handshake time incl. TLS
                    '"upstream_header_time": "$upstream_header_time", ' # time spent receiving upstream headers
                    '"upstream_response_time": "$upstream_response_time", ' # time spend receiving upstream body
                    '"upstream_response_length": "$upstream_response_length", ' # upstream response length
                    '"upstream_cache_status": "$upstream_cache_status", ' # cache HIT/MISS where applicable
                    '"ssl_protocol": "$ssl_protocol", ' # TLS protocol
                    '"ssl_cipher": "$ssl_cipher", ' # TLS cipher
                    '"scheme": "$scheme", ' # http or https
                    '"request_method": "$request_method", ' # request method
                    '"server_protocol": "$server_protocol", ' # request protocol, like HTTP/1.1 or HTTP/2.0
                    '"pipe": "$pipe", ' # "p" if request was pipelined, "." otherwise
                    '"gzip_ratio": "$gzip_ratio", '
                    '"http_cf_ray": "$http_cf_ray",'
                    '"geoip_country_code": "$geoip_country_code"'
                    '}';
```



#### 7 遇到的问题

（1） 启动的时候报错

**nginx open() “***” failed (13: Permission denied)**

```shell
查看SELinux状态
运行命令getenforce，验证SELinux状态。
返回状态如果是enforcing，表明SELinux已开启。

选择临时关闭或者永久关闭SELinux
执行命令setenforce 0临时关闭SELinux。

永久关闭SElinux。

运行以下命令，编辑SELinux的config文件。

vi /etc/selinux/config
找到SELINUX=enforcing，按i进入编辑模式，将参数修改为SELINUX=disabled
```

https://blog.csdn.net/qq_26545503/article/details/119335691



#### 8 配置文件

[分享一个nginx生产配置文件](https://blog.csdn.net/qq_39677803/article/details/121145433)



##### events指令配置模板

```
events{
	accept_mutex on;    # 开启 Nginx 网络连接序列化
	multi_accept on;    # 开启同时接收多个网络连接
	worker_commections 1024;   # 单个 worker 进程最大的连接数
	use epoll;   # 使用 epoll 函数来优化 Nginx
}
```

#### 9 斜杠总结

这里将发送 `http://192.168.199.27/kele/kbt` 请求。

**不带字符串情况**

| 案例 | localtion | proxy_pass             | 匹配      |
| ---- | --------- | ---------------------- | --------- |
| 1    | /kele     | http://192.168.199.27  | /kele/kbt |
| 2    | /kele/    | http://192.168.199.27  | /kele/kbt |
| 3    | /kele     | http://192.168.199.27/ | //kbt     |
| 4    | /kele/    | http://192.168.199.27/ | /kbt      |



若 Nginx 会将原请求路径原封不动地转交给其他地址，如案例 3 和 4。

`proxy_pass` 的 ip:port 后加了 `/`，代表去除掉请求和 location 的匹配的字符串，不加则追加全部请求到地址后面。



**带字符串情况**

| 案例 | localtion | proxy_pass                  | 匹配       |
| ---- | --------- | --------------------------- | ---------- |
| 1    | /kele     | http://192.168.199.27/bing  | /bing/kbt  |
| 2    | /kele/    | http://192.168.199.27/bing  | /bingkbt   |
| 3    | /kele     | http://192.168.199.27/bing/ | /bing//kbt |
| 4    | /kele/    | http://192.168.199.27/bing/ | /bing/kbt  |



`proxy_pass` 的 ip:port 后加了字符串，Nginx 会将匹配 location 的请求从「原请求路径」中剔除，再不匹配的字符串拼接到 proxy_pass 后生成「新请求路径」，然后将「新请求路径」转交给其他地址。

案例 2 中，`proxy_pass` 的 ip:port 后接了字符串，因此将 location 的 `/kele/` 从原请求路径 `/kele/kbt` 中剔除，变为 `kbt`，然后将 `kbt` 拼接到 `http://192.168.1.48/bing` 后生成了新请求，因此其他地址收到的请求就是 `/bingkbt`。



#### 10 Proxy Buffer 相关指令

- `proxy_buffering` 指令用来开启或者关闭代理服务器的缓冲区，默认开启。

  | 语法                         | 默认值              | 位置                   |
  | ---------------------------- | ------------------- | ---------------------- |
  | proxy_buffering <on \| off>; | proxy_buffering on; | http、server、location |

- `proxy_buffers` 指令用来指定单个连接从代理服务器读取响应的缓存区的个数和大小。

  | 语法                           | 默认值                                    | 位置                   |
  | ------------------------------ | ----------------------------------------- | ---------------------- |
  | proxy_buffers <number> <size>; | proxy_buffers 8 4k \| 8K;(与系统平台有关) | http、server、location |

  - number：缓冲区的个数
  - size：每个缓冲区的大小，缓冲区的总大小就是 number * size

- `proxy_buffer_size` 指令用来设置从被代理服务器获取的第一部分响应数据的大小。保持与 proxy_buffers 中的 size 一致即可，当然也可以更小。

  | 语法                      | 默认值                                      | 位置                   |
  | ------------------------- | ------------------------------------------- | ---------------------- |
  | proxy_buffer_size <size>; | proxy_buffer_size 4k \| 8k;(与系统平台有关) | http、server、location |

- `proxy_busy_buffers_size` 指令用来限制同时处于 BUSY 状态的缓冲总大小。

  | 语法                            | 默认值                             | 位置                   |
  | ------------------------------- | ---------------------------------- | ---------------------- |
  | proxy_busy_buffers_size <size>; | proxy_busy_buffers_size 8k \| 16K; | http、server、location |

- `proxy_temp_path` 指令用于当缓冲区存满后，仍未被 Nginx 服务器完全接受，响应数据就会被临时存放在磁盘文件上的该指令设置的文件路径下

  | 语法                    | 默认值                      | 位置                   |
  | ----------------------- | --------------------------- | ---------------------- |
  | proxy_temp_path <path>; | proxy_temp_path proxy_temp; | http、server、location |

  注意 path 最多设置三层。

- `proxy_temp_file_write_size` 指令用来设置磁盘上缓冲文件的大小。

  | 语法                               | 默认值                                | 位置                   |
  | ---------------------------------- | ------------------------------------- | ---------------------- |
  | proxy_temp_file_write_size <size>; | proxy_temp_file_write_size 8K \| 16K; | http、server、location |

**网站调优模板(通用)**

```
proxy_buffering on;
proxy_buffers 4 64k;
proxy_buffer_size 64k;
proxy_busy_buffers_size 128k;
proxy_temp_file_write_size 128k;
```

### 7 Nginx - 站点与认证

**制作下载站点**

```
location /download {
    root /opt;                # 下载目录所在的路径，location 后面的 /download 拼接到 /opt 后面
    # 以这些后缀的文件点击后为下载，注释掉则 txt 等文件是在网页打开并查看内容
    if ($request_filename ~* ^.*?\.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx|conf)$){
			  add_header Content-Disposition 'attachment;';
		  }
    autoindex on;			  # 启用目录列表的输出
    autoindex_exact_size on;  # 在目录列表展示文件的详细大小
    autoindex_format html;	  # 设置目录列表的格式为 html
    autoindex_localtime on;   # 目录列表上显示系统时间
}
```

### 8 性能优化 – 配置文件优化



#### **1.调整参数隐藏Nginx版本号信息**

 一般来说，软件的漏洞都和版本有关，因此我们应尽量隐藏或清除Web服务队访问的用户显示各类敏感信息（例如：Web软件名称及版本号等信息），这样恶意的用户就很难猜到他攻击的服务器所用的是否是特定漏洞的软件，或者是否有对应的漏洞存在。

**修改Nginx版本信息**

```
# vim /application/nginx/conf/nginx.conf
http{
  server_tokens off;
}
```

#### **2.更改源码隐藏Nginx软件名及版本号**

 隐藏了Nginx版本号后，更进一步，可以通过一些手段把web服务软件的名称也给因此，或者更改为其他Web服务软件名迷惑黑客。Nginx模块不支持更改软件名，所以我们需要更改Nginx源代码才能解决。

**1.第一步是一次修改3个Nginx源码文件**

修改的第一个文件为nginx-1.6.3/src/core/nginx.h

```
[root@web02 ~]# cd /home/oldboy/tools/nginx-1.6.3/src/core/[root@web02 core]# vim nginx.h #define NGINX_VERSION      "9.9.9"#修改为想要的版本号#define NGINX_VER          "ABCDOCKER/" NGINX_VERSION#将nginx修改想要修改的软件名称#define NGINX_VAR          "ABCDOCKER"#将nginx修改为想要修改的软件名称。#define NGX_OLDPID_EXT     ".oldbin"
```

**2.第二步修改nginx-1.6.3/src/http/ngx_http_header_filter_module.c的第49行**

```
[root@web02 nginx-1.6.3]# vim src/http/ngx_http_header_filter_module.c static char ngx_http_server_string[] = "Server: ABCDOCKER"    CRLF;#修改本行，此处的文件是我们Curl 出来显示的名称
```

**3.第三步修改nginx-1.6.3/src/http/ngx_http_special_response.c，对外页面报错时，它会控制是否展示敏感信息。修改28~30行**

```
[root@web02 nginx-1.6.3]# vim src/http/ngx_http_special_response.c  21 static u_char ngx_http_error_full_tail[] = 22 ""ABC(www.abcdocker.com)"" CRLF 23 "" CRLF 24 "" CRLF 25 ; 26  27  28 static u_char ngx_http_error_tail[] = 29 "ABC(www.abcdocker.com)" CRLF 30 "" CRLF 31 "" CRLF
```

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_60dd7383-55ce-46dd-9431-f1859881190d.png) **5.修改完成之后需要重新编译nginx**

查看原来编译的参数

```
[root@web02 nginx-1.6.3]# /application/nginx/sbin/nginx -Vnginx version: nginx/1.6.3built by gcc 4.4.7 20120313 (Red Hat 4.4.7-16) (GCC) TLS SNI support enabledconfigure arguments: --prefix=/application/nginx-1.6.3/ --user=www --group=www --with-http_ssl_module --with-http_stub_status_module[root@web02 nginx-1.6.3]# ./configure --prefix=/application/nginx-1.6.3/ --user=www --group=www --with-http_ssl_module --with-http_stub_status_module提示：需要停止原来的nginx，从新进行编译。如果不想在覆盖原来的编译参数可以选择指定新的目录。
```

**提示：最后还需要make makeinstall 才会生效**

测试：需要开启nginx

```
[root@web02 application]# curl -I blog.etiantian.orgHTTP/1.1 200 OKServer: ABCDOCKERDate: Mon, 30 May 2016 12:07:19 GMTContent-Type: text/html; charset=UTF-8Connection: keep-aliveX-Powered-By: PHP/5.5.32Link: ; rel="https://api.w.org/"
```

因为我优化了，所以Server：后面除了我设置的字母不会显示版本信息，修改配置文件server_tokens off; 修改为on即可

  **重启nginx**

```
[root@web02 application]# curl -I blog.etiantian.orgHTTP/1.1 200 OKServer: ABCDOCKER/9.9.9Date: Mon, 30 May 2016 12:09:05 GMTContent-Type: text/html; charset=UTF-8Connection: keep-aliveX-Powered-By: PHP/5.5.32Link: ; rel="https://api.w.org/"
```

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_1f88ad3f-31bf-4978-b638-9deb23c71bfc.png) 关闭server_tokens off; 可以显示我们设置的错误

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_b9584433-99b6-4e04-9149-f78639e21d75.png) **说明：**

1.提示网站安全，要从最简单、最短板、最低点入手解决问题，门大开着，窗户安装再结实的护栏也没有意义。

2.向有经验的人及优秀的网站公司学习。

3.学习看官方文档，根据一手资料去分析

4.命令输出结果中含有需要过滤或者要保留的内容时，命令自身可能有参数直接实现。

#### 3.更改Nginx服务的默认用户

 为了Web服务更安全，我们要尽可能地改掉软件默认的所有配置，包括端口、用户等。

查看nginx服务对应的默认用户，查看默认配置文件

```
[root@web02 ~]# grep "#user" /application/nginx/conf/nginx.conf.default #user  nobody;
```

 为了防止黑客猜到这个Web服务用户，我们需要更改成特殊的用户名，但这个用户必须是系统事先存在的

（1）为Nginx服务建立新用户

```
[root@web02 ~]# useradd nginx -s /sbin/nologin -M[root@web02 ~]# id nginx
```

（2）配置Nginx服务，让其使用刚建立的nginx用户

**更改ningx服务默认使用的用户方法有两种：**

第一种为直接更改配置文件参数，将默认的#user nobody修改如下内容

```
user nginx nginx;#在http标签即可
```

如果注释或不设置上述参数，默认即是nobody用户，不推荐使用。最好采用一个普通用户

第二种为直接在编译nginx软件时指定编译的用户和组

```
./configure --prefix=/application/nginx-1.6.3/ --user=www --group=www --with-http_ssl_module --with-http_stub_status_module
```

提示：前文在编译nginx服务时，就是这样带着参数，因此配置文件中加不加参数默认都是nginx用户了。

 通过上述修改后Nginx进程，可以看到worker processes进程对应的用户都变成了nginx

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_88f65d9b-0c66-4e48-bcaa-8463d83f315f.png)

#### 4.优化Nginx服务的worker进程个数

 在高并发、访问量的Web服务场景，需要事先启动好更多的nginx进程，以保证快速响应并处理大量并发用户的请求.

优化Nginx进程对应nginx服务的配置参数如下：

```
worker_processes  1;
```

 上述参数调整的是Nginx服务的Worker进程数，Nginx有Master进程和Worker进程之分，Master为管理进程，worker是工作进程

下面介绍Linux服务CPU总核数的方法

```
[abcdocker@web02 ~]$ grep "processor" /proc/cpuinfo |wc -l1[abcdocker@web02 ~]$ grep -c processor /proc/cpuinfo 1#此处的1表示1颗1核的CPU
```

查看cpu总颗数

```
[abcdocker@web02 ~]$ grep "pysical id" /proc/cpuinfo |sort|uniq|wc -l1  #对phsical id 去重计算，表示1颗CPU
```

执行top命令，然后按数字1，即可显示所有的cpu核数，如下

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_3736bf45-9787-43d8-8ae8-e04706967722.jpg) 单核CPU显示如下：

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_98bdcf25-1eb5-4027-a0fc-8bf25515afb2.png) 有关worker_process参数的官方说明如下：

```
syntax：    worker_processes number：#此行为参数语法，number为数量default：    worker_processes 1    #此行意思是不配置该参数，软件默认情况为1context：    main               #此行为worker_processes参数可以放置的位置worker_processes为定义worker进程数的数量，建议设置为CPU的核数或者cpu核数*2的进程数，具体情况要根据实际业务来进行选择。除了要和CPU核数的匹配外，和硬盘存储的数据以及系统的负载也会有关，设置为CPU的个数或核数是一个好的起始配置
```

#### 5.优化绑定不同的Nginx进程到不同CPU上

默认情况Nginx的多个进程有可能跑在某一个或某一核的CPU上，导致Nginx进程使用硬件的资源不均。可以分配不同的Nginx进程给不同的CPU处理，达到充分有效利用硬件的多CPU多核资源的目的。

```
worker_processes  1;worker_cpu_affinity 0001 0010 0100 1000;#worker_cpu_affinity就是配置nginx进程CPU亲和力的参数，即把不同的进程分给不同的CPU处理。这里0001 0010 0100 1000是掩码，分别代表1、2、3、4核cpu核心，由于worker_processes进程数为4，因此上述配置会把每个进程分配一核CPU处理，默认情况下进程不会绑定任何CPU，参数位置为main段
```

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_269f85dd-5a6a-4911-b061-058bda8eca39.jpg) worker_cpu_affinity参数的官方说明如下：

```
syntax：    worker_cpu_affinity cpumask.....#此行为cpu亲和力参数语法，cpumask为cpu掩码default：    ---                                            #默认不配置context：    main                            #此行为worker_cpu_affinty参数可以放置的位置
```

 worker_cpu_affinity的作用是绑定不同的worker进程到一组CPU上。通过设置bitmask控制允许使用的CPUS，默认worker进程不会绑定到任何CPUS。

参考：

```
worker_processes    4;worker_cpu_affinity 0001 0010 0100 1000;binds each worker process to a separate CPU, whileworker_processes    2;worker_cpu_affinity 0101 1010;binds the first worker process to CPU0/CPU2, and the second worker process to CPU1/CPU3. The second example is suitable for hyper-threading.The directive is only available on FreeBSD and Linux.From : http://nginx.org/en/docs/ngx_core_module.html by oldboy 
```

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_5525eb50-b318-4539-8b23-06c078258c88.jpg)  通过观察，我们发现配置后不同CPU的使用率相对平均，和测试前变化不大。可能是Nginx软件本身在逐渐变化，使其使用多核CPU时更为均衡。

 另外(taskset - retrieve or set a process’s CPU affinity)命令本身也有分配CPU的功能，（例如：taskset -c 1,2,3 /etc/init.d/mysqld start）。

#### 6.Nginx事件处理模型优化

 Nginx的连接处理机制在于不同的操作系统会采用不同的I/O模型，在Linux下，Nginx使用epoll的I/O多路复用模型，在Freebsd中使用kqueue的I/O多路复用模型，在Solaris中使用/dev/poll方式的I/O多路复用模型，在Windows使用的是icop，等待。

 要根据系统类型选择不同的事件处理模型，可供使用的选择的有“use [kqueue|rtsig|epoll|/dev/poll|select|pokk]”。

企业面试题Nginx epool和apache select有什么区别？

http://www.tuicool.com/articles/AzmiY3

宿管大妈的例子

具体配置如下：

```
events {#events指令是设定Nginx的工作模式及连接数上限use epoll}#use是个事件模块指定，用来指定Nginx的工作模式，Nginx支持的工作模式有select、poll、kqueue、epoll、rtsig和/dev/poll。其中select和poll都是标准的工作迷失，kqueue和epoll是高效工作模式，不同的是epoll用在Linux平台，而kqueue用在BSD系统中。对于Linux 2.6内核推荐使用epoll工作模式
```

根据Nginx的官方文档建议，也可以不指定事件处理模型，Nginx会自动选择最佳的事件处理模型服务。

#### 7.调整Nginx单个进程允许的客户端最大连接数

 调整Nginx单个进程允许客户端的最大连接数，这个控制连接数的参数为

```
    worker_connections  1024;
```

worker_connections的值要根据具体服务器性能和程序的内存使用量来指定（一个进程启动使用的内存根据程序确定）

```
events {    worker_connections  20480;}#worker_connections 也是个事件模块指令，用于定义Nginx每个进程的最大连接数，默认是1024.最大客户端连接数由worker_processes和worker_connections决定. 并发=worker_process * worker_connections 
```

参考资料：http:nginx.org/en/docs/ngx_core_module.html

#### 8.配置Nginx worker进程最大打开文件数

 Nginx worker进程的最大打开文件数，这个控制连接数的参数为worker_rlimit_nofile。

```
worker_rlimit_nofile 65535#最大打开文件数，可设置为系统优化有的ulimit-HSn的结果。
```

worker_rlimit_nofile number的官方说明如下：

参数语法：worker_rlimit_nofile number；

默认配置：无

放置位置：主标签段

说明：此参数的作用是改变worker processes能打开的最大文件数。

参考资料：http://nginx.org/en/docs/ngx_core_module.html

#### 9.开启高效文件传输模式

**1.设置参数：sendfile on；**

 sendfile参数用于开启文件的高效传输模式，同时将tcp_nopush和tcp_nodelay两个指定设为on，可防止网络及磁盘I/O阻塞，提升Nginx工作效率。

**官方说明：**

```
syntax：    sendfile on|off  #参数语法default：    sendfile off    #参数默认大小context：    http，server，location，if in location #可放置的标签段
```

参数作用：激活或者禁用sendfile()功能。sendfile()是作用于两个文件描述符之间的数据拷贝函数，这个拷贝操作是在内核之中，被称为“零拷贝”，sendfile()和read和write函数要高效很多，因为read和wrtie函数要把数据拷贝到应用层再进行操作。相关控制参数还有sendfile_max_chunk。

http://nginx.org/en/docs/http/ngx_http_core_module.html#sendfile

**2.设置参数：tcp_nopush on；**

```
Syntax:  tcp_nopush on | off;  #参数语法Default:   tcp_nopush off;      #参数默认大小Context:    http, server, location  #可以放置标签段
```

参数作用：激活或禁用Linux上的TCP_CORK socker选项，此选项仅仅开启sendfile时才生效，激活这个tcp_nopush参数可以运行把http response header和文件的开始放在一个文件里发布，减少网络报文段的数量。

http://nginx.org/en/docs/http/ngx_http_core_module.html#tcp_nodelay

**3.设置参数：tcp_nodelay on；**

 用于激活tcp_nodelay功能，提高I/O性能

```
Syntax:    tcp_nodelay on | off;Default:  tcp_nodelay on;Context:    http, server, location
```

参数作用：默认情况下数据发送时，内核并不会马上发送，可能会等待更多的字节组成一个数据包，这样可以提高I/O性能，但是，在每次只发送很少字节的业务场景，使用tcp_nodelay功能，等待时间会比较长。

 参数生产条件：激活或禁用tcp_nodelay选项，当一个连接进入到keep-alive状态时生效

http://nginx.org/en/docs/http/ngx_http_core_module.html#tcp_nopush

#### 10.优化Nginx连接参数调整连接超时时间

**1、什么是连接超时？**

 这里的服务员相当于Nginx服务建立的连接，当服务器建立的连接没有接收到处理请求时，可在指定的事件内就让它超时自动退出。还有当Nginx和fastcgi服务建立连接请求PHP时，如果因为一些原因（负载高、停止响应）fastcgi服务无法给Nginx返回数据，此时可以通过配置Nginx服务参数使其不会四等。例如：可设置如果Fastcgi 10秒内不能返回数据，那么Nginx就终端本次请求。

**2、连接超时的作用**

1）设置将无用的连接尽快超时，可以保护服务器的系统资源（CPU、内存、磁盘）

2）当连接很多时，及时断掉那些已经建立好的但又长时间不做事的连接，以减少其占用的服务器资源，因为服务器维护连接也是消耗资源的。

3）有时黑客或而恶意用户攻击网站，就会不断和服务器建立多个连接，消耗连接数，但是什么也不操作。只是持续建立连接，这就会大量的消耗服务器的资源，此时就应该及时断掉这些恶意占用资源的连接。

4）LNMP环境中，如果用户请求了动态服务，则Nginx就会建立连接请求fastcgi服务以及MySQL服务，此时这个Nginx连接就要设定一个超时时间，在用户容忍的时间内返回数据，或者再多等一会后端服务返回数据，具体策略要看业务。

**3.连接超时带来的问题以及不同程序连接设定知识**

 服务器建立新连接也是要消耗资源的，因此，超时设置的太短而并发很大，就会导致服务器瞬间无法响应用户的请求，导致体验下降。

 企业生产有些PHP程序站点就会系统设置短连接，因为PHP程序建立连接消耗的资源和时间相对要少些。而对于java程序站点一般建议设置长连接，因为java程序建立消耗的资源和时间更多。

**4.Nginx连接超时的参数设置**

**（1）设置参数：keeplived_timeout 60;**

 用于设置客户端连接保持会话的超时时间为60秒。超过这个时间，服务器会关闭该连接，此数值为参考值。

```
Syntax:   keepalive_timeout timeout [header_timeout]; #参数语法Default:  keepalive_timeout 75s;  #参数默认大小Context:    http, server, location   #可以放置的标签段
```

 参数作用：keep-alive可以使客户端到服务端已经建立的连接一直工作不退出，当服务器有持续请求时，keep-alive会使用正在建立的连接提供服务，从而避免服务器重新建立新连接处理请求。

**（2）设置参数：client_header_timeout 15；**

用于设置读取客户端请求头数据的超时时间，此处的数值15单位是秒。

Syntax: client_header_timeout time;

Default: client_header_timeout 60s;

Context: http, server

参数作用：设置读取客户端请求头数据的超时时间。如果超过这个时间，客户端还没有发送完整的header数据，服务端将数据返回“Request time out （408）”错误。

**（3）设置参数：client_body_timeout 15；**

```
用于设置读取客户端请求主体的超时时间，默认值是60Syntax:   client_body_timeout time;Default:  client_body_timeout 60s;Context:   http, server, location
```

参数作用：设置读取客户端请求主体的超时时间。这个超时仅仅为两次成功的读取操作之间的一个超时，非请求整个主体数据的超时时间，如果在这个超时时间内，客户端没有发送任何数据，Nginx将返回“Request time out（408）”错误，默认值是60.

http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_timeout

**（4）设置参数：send_timeout 25；**

  用户指定响应客户端的超时时间。这个超时时间仅限于两个链接活动之间的事件，如果超过这个时间，客户端没有任何活动，Nginx将会关闭连接，默认值为60s，可以改为参考值25s

```
Syntax:   send_timeout time;Default:     send_timeout 60s;Context:  http, server, location
```

参数作用：设置服务器端传送http响应信息到客户端的超时时间，这个超时时间仅仅为两次成功握手后的一个超时，非请求整个响应数据的超时时间，如在这个超时时间内，客户端没有收到任何数据，连接将被关闭。

http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_timeout

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_a7e50a3b-edf6-40ab-956f-5a643af33adf.jpg) **操作步骤**

```
一般放在http标签即可http {sendfile        on;tcp_nopush on;tcp_nodelay on;server_tokens off;server_names_hash_bucket_size 128;server_names_hash_max_size 512;keepalive_timeout  65;client_header_timeout 15s;client_body_timeout 15s;send_timeout 60s;}
```

**配置参数介绍如下：**

keeplived_timeout 60;

\###设置客户端连接保持会话的超时时间，超过这个时间，服务器会关闭该连接。

tcp_nodelay on;

\####打开tcp_nodelay，在包含了keepalive参数才有效

client_header_timeout 15;

\####设置客户端请求头读取超时时间，如果超过这个时间，客户端还没有发送任何数据，Nginx将返回“Request time out（408）”错误

client_body_timeout 15;

\####设置客户端请求主体读取超时时间，如果超过这个时间，客户端还没有发送任何数据，Nginx将返回“Request time out（408）”错误

send_timeout 15;

\####指定响应客户端的超时时间。这个超过仅限于两个连接活动之间的时间，如果超过这个时间，客户端没有任何活动，Nginx将会关闭连接。

**优化服务器域名的bash表大小**

 哈希表和监听端口关联，每个端口都是最多关联到三张表：确切名字的哈希表，以星号起始的通配符名字的哈希表和以星号结束的统配符名字的哈希表。哈希表的尺寸在配置阶段进行了优化，可以以最小的CPU缓存命中率失败来找到名字。Nginx首先会搜索确切名字的哈希表，如果没有找到，则搜索以星号起始的通配符名称的哈希表，如果还是没有找到，继续搜索以星号结束的通配符名字的哈希表。

 注意.nginx.org存储在通配符名字的哈希表中，而不在明确名字的哈希表中，由于正则表达式是一个个串行测试的，因此该方式也是最慢的，并且不可扩展。

举个例子，如果Nginx.org和www.nginx.org来访问服务器最频繁，那么明确的定义出来更为有效

```
    server {        listen       80;        server_name  nginx.org  www.nginx.org *.nginx.org        location / {            root   html/www;            index  index.php index.html index.htm;        }
```

server_names_hash_bucket_size size的值，具体信息如下

```
server_names_hash_bucket_size size 512；
```

\#默认是512KB 一般要看系统给出确切的值。这里一般是cpu L1的4-5倍

**官方说明：**

```
Syntax:     server_names_hash_bucket_size size;Default:    server_names_hash_bucket_size 32|64|128;Context:   http
```

参数作用：设置存放域名（server names）的最大哈希表大小。

#### **11.上传文件大小（http Request body size）的限制（动态应用）**

设置上传文件大小需要在nginx的主配置文件加入如下参数

```
client_max_body_size 8m;
```

 具体大小根据公司的业务调整，如果不清楚设置为8m即可

```
Syntax:    client_max_body_size size;Default:     client_max_body_size 1m;  #默认值是1mContext:     http, server, location
```

参数作用：设置最大的允许客户端请求主体大小，在请求头域有“Content-Length”，如果超过了此配置值，客户端会收到413错误，意思是请求的条目过大，有可能浏览器不能正确的显示这个错误，设置为0表示禁止检查客户端请求主体大小，此参数对服务端的安全有一定的作用。

http://nginx.org/en/docs/http/ngx_http_core_module.html

#### **12.fastcgi相关参数调优（配合PHP引擎动态服务）**

 fastcgi参数是配合nginx向后请求PHP动态引擎服务的相关参数

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_c27ee8d5-87b2-4912-947c-703faa13a9b8.jpg)**Nginx Fastcgi常见参数列表说明**

Nginx Fastcgi相关参数 说明 fastcgi_connect_timeout 表示nginx服务器和后端FastCGI服务器连接的超时时间，默认值为60s，这个参数通常不要超过75s，因为建立的连接越多消耗的资源就越多 fastcgi_send_timeout 设置nginx允许FastCGI服务返回数据的超时时间，即在规定时间之内后端服务器必须传完所有的数据，否则，nginx将断开这个连接，默认值为60s fastcgi_read_timeout 设置Nginx从FastCGI服务端读取响应信息的超时时间。表示建立连接成功后，nginx等待后端服务器的响应时间，是nginx已经进入后端的排队之中等候处理的时间 fastcgi_buffer_size 这是nginx fastcgi的缓冲区大小参数，设定用来读取FastCGI服务端收到的第一部分响应信息的缓冲区大小，这里的第一部分通常会包含一个小的响应头部，默认情况，这个参数大小是由fastcgi_buffers指定的一个缓冲区的大小 fastcgi_buffers 设定用来读取从FastCGI服务端收到的响应信息的缓冲区大小以及缓冲区数量。默认值fastcgi_buffers 8 4|8k；

指定本地需要用多少和多大的缓冲区来缓冲FastCGI的应答请求。如果一个PHP脚本所产生的页面大小为256lb，那么会为其分配4个64kb的缓存区用来缓存。如果站点大部分脚本所产生的页面大小为256kb，那么可以把这个值设置为“16 16k”、“464k”等 fastcgi_busy_buffers_size 用于设置系统很忙时可以使用fastcgi_buffers大小，官方推荐的大小为fastcgi_buffers*2

默认fastcgi_busy_buffers_size 8k|16k fastcgi_temp_file_write_size fastcgi临时文件的大小，可设置128-256k fastcgi_cache oldboy_nginx 表示开启FastCGI缓存并为其指定一个名称。开启缓存非常有用，可以有效降低CPU的负载，并且防止502错误的发送，但是开启缓存也会引起其他问题，要根据具体情况选择。 fastcgi_cache_path ![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_fascg.png)fastcgi_cache缓存目录，可以设置目录哈希层级。比如2:2会生成256*256个子目录，keys_zene是这个缓存空间的名字，cache是用多少内存(这样热门的内容nginx直接放入内存，提高访问速度)，inactive表示默认失效时间，max_size表示最多用多少硬盘空间，需要注意的是fastcgi_cache缓存是先卸载fastcgi_temp_path再移到fastcgi_cache_path。所以这两个目录最好在同一个分区

```
   fastcgi_cache_vaild 示例：fastcgi_cache_valid 2000 302 1h;
```

用来指定应答代码的缓存时间，实例中的值将200和302应答缓存一个小时

```
示例：fastcgi_cache_valid 301 1d;
```

将304应该缓存1天。

还可以设置缓存1分钟（1m）

```
   fastcgi_cache_min_user 示例：fastcgi_cache_min_user 1;
```

设置请求几次之后响应将被缓存。

```
   fastcgi_cache_user_stale 示例：fastcgi_cache_use_stale error timeout invaild_header http_500;
```

定义那些情况下用过期缓存

fastcgi_cache_key 示例：fastcgi_cache_key $request_method://$host$request_uri;

fastcgi_cache_key [http://$host$request_uri;](http://$host$request_uri;/)定义fastcgi_cache的key，示例中就以请求的URI作为缓存的key，nginx会取这个key的md5作为缓存文件，如果设置了缓存哈希目录，Nginx会从后往前取响应的位置作为目录。注意一定要加上$request_method作为cache key，否则如果HEAD类型的先请求会导致后面的GET请求返回为空

fastcgi cache资料：http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_cache

**PHP 优化设置：**

在http{}里面

```
fastcgi_connect_timeout 240;fastcgi_send_timeout 240;fastcgi_read_timeout 240;fastcgi_buffer_size 64k;fastcgi_buffers 4 64k;fastcgi_busy_buffers_size 128k;fastcgi_temp_file_write_size 128k;#fastcgi_temp_path /data/ngx_fcgi_tmp;  需要有路径fastcgi_cache_path /data/ngx_fcgi_cache levels=2:2 keys_zone=ngx_fcgi_cache:512m inactive=1d max_size=40g;
```

PHP缓存 可以配置在server标签和http标签

```
fastcgi_cache ngx_fcgi_cache; fastcgi_cache_valid 200 302 1h;fastcgi_cache_valid 301 1d;fastcgi_cache_valid any 1m;fastcgi_cache_min_uses 1;fastcgi_cache_use_stale error timeout invalid_header http_500;fastcgi_cache_key http://$host$request_uri;
```

![[Nginx] – 性能优化 – 配置文件优化 [一]](https://cdn.i4t.com/uploads/2016/08/90d46d32faf5496a81b9c13b26bc7733_55fcffa0-528e-4ca0-997e-3ed74f814786.jpg) 2个模块地址

http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_buffer_siz

http://nginx.org/en/docs/http/ngx_http_proxy_module.html



### 9 安全优化 – 配置文件优化

#### 1 配置`Nginx gzip`压缩实现性能优化

**1.Nginx gzip压缩功能介绍**

Nginx gzip压缩模块提供了压缩文件内容的功能，用户请求的内容在发送出用客户端之前，Nginx服务器会根据一些具体的策略实施压缩，以节约网站出口带宽，同时加快了数据传输效率，提升了用户访问体验。

**2.Nginx gzip 压缩的优点**

1.提升网站用户体验：由于发给用户的内容小了，所以用户访问单位大小的页面就快了，用户体验提升了，网站口碑就好了。

2.节约网站带宽成本，由于数据是压缩传输的，因此，此举节省了网站的带宽流量成本，不过压缩会稍微消耗一些CPU资源，这个一般可以忽略。此功能既能让用户体验增强，公司也少花钱。对于几乎所有的Web服务来说，这是一个非常重要的功能，Apache服务也由此功能。

3.需要和不需要压缩的对象

1、纯文本内容压缩比很高，因此纯文本内容是最好压缩，例如：html、js、css、xml、shtml等格式的文件

2、被压缩的纯文本文件必须要大于1KB，由于压缩算法的特殊原因，极小的文件压缩可能反而变大。

3、图片、视频（流媒体）等文件尽量不要压缩，因为这些文件大多数都是经历压缩的，如果再压缩很坑不会减小或减少很少，或者可能增加。而在压缩时还会消耗大量的CPU、内存资源

4、参数介绍及配置说明

此压缩功能很类似早起的Apache服务的`mod_defalate`压缩功能，Nginx的gzip压缩功能依赖于`ngx_http_gzip_module`模块，默认已安装。

**参数说明如下：**

```
gzip on; #开启gzip压缩功能 gzip_min_length 1k;#设置允许压缩的页面最小字节数，页面字节数从header头的Content-Length中获取，默认值是0，表示不管页面多大都进行压缩，建议设置成大于1K，如果小于1K可能会越压越大 gzip_buffers 4 16k;#压缩缓冲区大小，表示申请4个单位为16K的内存作为压缩结果流缓存，默认是申请与原始是数据大小相同的内存空间来存储gzip压缩结果； gzip_http_version 1.1#压缩版本（默认1.1 前端为squid2.5时使用1.0）用于设置识别HTTP协议版本，默认是1.1，目前大部分浏览器已经支持GZIP压缩，使用默认即可。 gzip_comp_level 2;#压缩比率，用来指定GZIP压缩比，1压缩比最小，处理速度最快；9压缩比最大，传输速度快，但处理最慢，也消耗CPU资源 gzip_types  text/css text/xml application/javascript; #用来指定压缩的类型，“text/html”类型总是会被压缩，这个就是HTTP原理部分讲的媒体类型。 gzip_vary on;#vary hear支持，该选项可以让前端的缓存服务器缓存经过GZIP压缩的页面，例如用缓存经过Nginx压缩的数据。
```

配置在`http`标签端

```
http{gzip on;gzip_min_length  1k;gzip_buffers     4 32k;gzip_http_version 1.1;gzip_comp_level 9;gzip_types  text/css text/xml application/javascript; gzip_vary on;}
```

**设置完成之后重启Nginx服务器。**

并在`360` `火狐|` `谷歌` 等浏览器中安装插件`Firebug`和`YSlow` 进行查看页面压缩率

**例如：没有制作压缩图片**

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/4gs0btm04zfikm4tynqxwbv3/image_1b4t16l2e1hf22ir12sb1ukisd9.png)

制作后

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/0utgc91nnsntvfsev1yvpk8n/image_1b4t19ftsuh97c5bm2arrndmm.png)

#### 2 配置`Nginx expires`缓存实现性能优化

**1.Nginx expires 功能介绍**

简单地说，`Nginx expires`的功能就是为用户访问的网站内容设定一个国企时间，当用户第一次访问到这些内容时，会把这样内容存储在用户浏览器本地，这样用户第二次及此后继续访问网站，浏览器会检查加载缓存在用户浏览器本地的内容，就不会去服务器下载了。直到缓存的内容过期或被清除为止。

深入理解，expires的功能就是允许通过Nginx 配置文件控制HTTP的“`Expires`”和“`Cache-Contorl`”响应头部内容，告诉客户端刘琦是否缓存和缓存多久以内访问的内容。这个`expires模块`控制Nginx 服务器应答时Expires头内容和Cache-Control头的max-age指定。

这些HTTP头向客户端表名了内容的有效性和持久性。如果客户端本地有内容缓存，则内容就可以从缓存（除非已经过期）而不是从服务器读取，然后客户端会检查缓存中的副本。

**2.Nginx expires作用介绍**

在网站的开发和运营中，对于`图片` `视频` `css` `js`等网站元素的更改机会较少，特别是图片，这时可以将图片设置在客户端浏览器本地缓存`365`天或`3650`天，而降css、js、html等代码缓存`10~30`天，这样用户第一次打开页面后，会在本地的浏览器按照过期日期缓存响应的内容，下次用户再打开类似页面，重复的元素就无需下载了，从而加快了用户访问速度，由于用户的访问请求和数据减少了，因此节省了服务器端大量的带宽。此功能和`apache`的`expire`相似。

**3.Nginx expires 功能优点**

1.Expires可以降低网站的带宽，节约成本。

2.加快用户访问网站的速度，提升了用户访问体验。

3.服务器访问量降低了，服务器压力就减轻了，服务器成本也会降低，甚至可以解决人力成本。

对于几乎所有Web来说，这是非常重要的功能之一，Apache服务也由此功能。

**4. Nginx expires 配置详解**

1）根据文件扩展名进行判断，添加expires功能范例。

```
    location ~.*\.(gif|jpg|jpeg|png|bmp|swf)$       {          expires 3650d;      }
```

该范例的意思是当前用户访问网站URL结尾的文件扩展名为上述指定的各种类型的图片时，设置缓存`3650`天，即10年。

**提示：配置可以放在server标签，也可以放在http标签下配置**

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/pr349chlihjw8fymqcmv8lia/image_1b4t1es7v3m31jk47pl7sn1pbn13.png)

例如：

```
[root@web02 /]# curl -I www.jd.comHTTP/1.1 200 OKServer: jdwsDate: Mon, 25 Jul 2016 15:15:47 GMTContent-Type: text/html; charset=gbkContent-Length: 197220Connection: keep-aliveVary: Accept-EncodingExpires: Mon, 25 Jul 2016 15:15:38 GMT   #告诉用户什么时候过期Cache-Control: max-age=20ser: 6.158Via: BJ-M-YZ-NX-74(HIT), http/1.1 BJ-UNI-1-JCS-117 ( [cRs f ])Age: 16
```

2）根据URI中的路径（目录）进行判断，添加expires功能范例。

```
location ~^/(images|javascript|js|css|flash|media|static)/ {  expires 360d;}
```

意思是当用户访问URI中包含上述路径（例：`images` `js` `css` 这些在服务端是`程序目录`）时，把访问的内容设置缓存360天，即1年。如果要想缓存30天，设置30d即可。

```
HTTP/1.1 200 OKServer: JDWSDate: Mon, 25 Jul 2016 16:00:32 GMTContent-Type: text/html; charset=gbkVary: Accept-EncodingExpires: Mon, 25 Jul 2016 16:00:48 GMT    #<==缓存的过期时间Cache-Control: max-age=20                      #<==缓存的总时间按秒，单位ser: 130.29Via: BJ-Y-NX-104(HIT), http/1.1 HK-1-JCS-70 ( [cRs f ])Age: 14Content-Length: 197220
```

**5.Nginx expires功能缺点及解决方法**

当网站被缓存的页面或数据更新了，此时用户看到的可能还是旧的已经缓存的内容，这样会影响用户体验。

对经常需要变动的图片等文件，可以缩短对象缓存时间，例如：谷歌和百度的首页图片经常根据不同的日期换成一些节日的图，所以这里可以将图片设置为缓存期为1天。

当网站改版或更新内容时，可以在服务器将缓存的对象改名（网站代码程序）。

1.对于网站的图片、软件，一般不会被用户直接修改，用户层面上的修改图片，实际上是重新传到服务器，虽然内容一样但是是一个新的图片名了

2.网站改版升级会修改JS、CSS元素，若改版的时候对这些元素该了名，会使得前端的CDN以及用户需要重新缓存内容。

**6.企业网站缓存日期曾经的案例参考**

若企业的业务和访问量不同，那么网站的缓存期时间设置也是不同的，比如：

a.51CTP：1周

b.sina：15天

c.京东：25年

d.淘宝：10年

**7.企业网站有可能不希望被缓存的内容**

1.广告图片，用于广告服务，都缓存了就不好控制展示了。

2.网站流量统计工具（js代码）都缓存了流量统计就不准了

3.更新很频繁的文件（google的logo），如果按天，缓存效果还是显著的。

#### Nginx`日志`相关优化与安装

**1.编写脚本脚本实现Nginx access日志轮询**

Nginx目前没有类似Apache的通过`cronlog`或者`rotatelog`对日志分割处理的能力，但是，运维人员可以通过利用脚本开发、Nginx的信号控制功能或reload重新加载，来实现日志自动切割，轮询。

（1）配置日志切割脚本

```
[root@web02 /]# mkdir /server/scripts/ -p[root@web02 /]# cd /server/scripts/[root@web02 scripts]# cat cut_nginx_log.shcd /application/nginx/logs && \/bin/mv www_access.log www_access_$(data +%F -d -1dy).log  #将日志按日志改成前一天的名称/application/nginx/sbin/nginx -s reload         #重新加载nginx使得重新生成访问日志文件
```

**提示：**实际上脚本的功能很简单，就是改名日志，然后加载nginx，重新生成文件记录日志。

（2）将这段脚本保存后加入到定时任务，设置每天凌晨0点进行切割日志

```
[root@web02 scripts]# crontab -e###cut nginx access log00 00 * * * /bin/sh /server/scripts/cut_nginx.log.sh >/dev/null 2>&1
```

解释：每天0点执行`cut_nginx_log.sh`脚本，将脚本的输出重定向到空。

**2.不记录不需要的访问日志**

对于负载均衡器健康检查节点或某些特定文件(比如图片、`js`、`css`)的日志，一般不需要记录下来，因为在统计PV时是按照页面计算的。而且日志写入频繁会大量消耗磁盘I/O，降低服务的性能。

具体配置如下：

```
     location ~ .*\.(js|jpg|JPG|jpeg|JPEG|css|bmp|gif|GIF)?$ {        access_log off; }
```

这里用`location`标签匹配不记录日志的元素扩展名，然后关掉了日志。

**3.访问日志的权限设置**

加入日志目录为`/app/logs` 则授权方法为：

```
chown -R root.root /app/logs/chmod -R 700 /app/logs
```

不需要在日志目录上给nginx用户读或写的许可。

#### 3 Nginx站点目录及文件URL访问控制

**1.根据扩展名限制程序和文件访问**

Web2.0时代，绝大多数网站都是以用户为中心，例如：BBS、blog、sns产品，这几个产品共同特点就是不但允许用户发布内容到服务器，还允许用户发图片甚至附件到服务器，由于为用户打开了上传的功能，因为给服务器带来了很大的安全风险。

下面将利用Nginx配置禁止访问上传资源目录下的PHP、shell、perl、Python程序文件，这样用户即使上传了木马文件也没法去执行，从而加强了网站的安全。

配置Nginx，限制禁止解析指定目录下的制定程序。

```
 location ~ ^/images/.*\.(php|php5|.sh|.pl|.py)$         {           deny all;         } location ~ ^/static/.*\.(php|php5|.sh|.pl|.py)$         {            deny all;         } location ~* ^/data/(attachment|avatar)/.*\.(php|php5)$     {         deny all;     } 
```

Nginx下配置禁止访问*.txt文件

```
location ~*\.(txt|doc)${    if (-f $request_filename) {    root /data/www/www;    #rewrite ....可以重定向某个URL    break;  }}location ~*\.(txt|doc)${    root /data/www/www;    deny all;}
```

对上述限制需要卸载`php`匹配的前面

```
　　location ~.*\.(php|php5)?${　fastcgi_pass 127.0.0.1:9000　fastcgi_index index.php　include fcgi.conf;}
```

对目录访问进行设置

**单目录**

```
 location ~ ^/(static)/ {        deny all;}location ~ ^/static {        deny all;}
```

**多目录**

```
 location ~ ^/(static)/ {        deny all;}
```

范例：禁止访问目录并返回指定的`http`状态码

```
location /admin/ { return 404; }location /templates/ { return 403; }
```

**限制网站来源IP访问**

案例环境：`phpmyadmin` 数据库的Web客户端，内部开发人员使用

禁止某目录让外界访问，但允许某IP访问该目录，切支持PHP解析

```
location ~ ^/docker/ { allow 202.111.12.211; deny all;}
```

**企业问题案例：** Nginx做反向代理的时候可以限制客户端IP吗？

解答：可以，具体方法如下。

```
方法1：使用if来控制。        if ( $remote_addr = 10.0.0.7 ) {        return 403;        }if ( $remote_addr = 218.247.17.130 ) {        set $allow_access_root 'true';}
```

#### 4 配置Nginx禁止非法域名解析访问企业网站

`Nginx`如何预防用户IP访问网站（恶意域名解析，相当于是直接IP访问企业网站）

让使用IP访问的网站用户，或者而已解析域名的用户，收到`501`错误

```
server {listen 80 default_server;server_name _;return 501;}
```

通过301跳转到主页。

```
server {listen 80 default_server;server_name _;rewrite ^(.*) http://www.abcdocker.com/$1 permanent;}
```

**要放在第一个server**

```
  if ($host !~ ^www/.abcdocker/.com$){    rewrite ^(.*)  http://www.abcdocker.com$1 permanent;}
```

如果header信息和host主机名字字段非`www.abcdocker.com`，就301跳转到`www.baidu.cn`

#### 5 Nginx图片及目录`防盗链`解决方案

**1.什么是资源盗链**

简单的说，就是某些不发的网站未经许可，通过在其自身网站程序里非法调用其他网站的资源吗，然后在自己的网站上显示。达到补充自身网站的效果，这一举动不但浪费了调用网站的流量，还造成服务器的压力，甚至宕机。

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/jx8xtmsnixw1bnxc9xruc77h/image_1b4t2o155shp1gh61ru01ef81mgj1g.png)

**2.网站资源被盗链带来的问题**

若网站图片及相关资源被盗链，最直接的影响就是网络带宽占用加大了，带宽费用多了，网站流量也可能忽高忽低，`nagios/zabbix`等报警服务频繁报警。

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/npwq1wdw2z5jaslec89ftfq6/image_1b4t2oua01igeck1c85v0bn1m1t.png)

最严重的情况就是网站的资源被非法使用，导致网站带宽成本加大和服务器压力加大，有可能会导致数万元的损失，且网站的正常用户访问也会受到影响。

**3.网站资源被盗链严重问题企业真实案例**

公司的CDN源站的流量没有变动，但是CDN加速那边的流量无故超了好几个GB，不知道怎么如理。

该故障的影响：

由于是购买的CDN网站加速服务，因此虽然流量多了几个GB，但是业务未受影响。只是，这么大的异常流量，持续下去可直接导致公司无故损失数万元。

**解决方案：**

第一，对IDC及CDN带宽做监控报警。

第二，作为高级运维或者运维经理，每天上班的重要任务，就是经常查看网站流量图，关注流量变化，关注异常流量

第三，对访问日志做分析，对于异常流量迅速定位，并且和公司市场推广等有比较好的默契沟通

相关博客：[轻松应对IDC机房带宽突然暴涨问题](http://oldboy.blog.51cto.com/2561410/909696)

**4.常见防盗链解决方案的基本原理**

(1)根据http referer 实现防盗链

在HTTP协议中，有一个表头字段叫referer，使用URL格式来表示哪里的链接用了当前网页的资源。通过referer可以检测目标访问的来源网页，如果是资源文件，可以跟踪到显示它的网页地址，一旦检测出来不是本站，马上进行阻止或返回指定的页面。

HTTP Referer是header的一部分，当浏览器向Web服务器发送请求的时候，一般会带上Referer，告诉服务器我是从哪个页面链接过来的，服务器籍此可以获得一些信息用于处理，Apache、Nginx、Lighttpd三者都支持根据http referer实现防盗链referer是目前网站图片、附件、html最常用的盗链手段。

```
     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '                       '$status $body_bytes_sent "$http_referer" '                       '"$http_user_agent" "$http_x_forwarded_for"'; #--> $http_referer
```

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/r2i1c1hsrct194qfkeeh9xx4/image_1b4t2spm61ti81s9j80p1ooq1eg02a.png)

(2)根据cookie防盗链

对于一些特殊的业务数据，例如流媒体应用以及通过Active X显示的内容（例如，Flash、Windows Media视频、流媒体的RTSP协议等）因为他们不向服务器提供Referer Header，所以若也采用上述的Referer的防盗链手段就达不到想要的结果。

对于视频这种占用流量较大的业务根据实现防盗链是比较困难的，此时可以采用Cookie技术，来解决对Flash、Windows Media视频等防盗链问题。

例如：Active X插件不传递Referer，但会传递Cookie。可以在显示Active X的页面的 标签内嵌入一段代码，可以用JavaScript 代码来设置一段`Cookie；Cache=av；`

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/j6kzfj89st4ln9uwq0c27gm1/image_1b4t2u09vq119ai14f111av1dr22n.png)

然后就可以通过各种手段来判断这个`Cookie`的存在以及验证其值的操作了。

(3)通过加密变换访问路径实现防盗链

此方法比较适合视频以及下载类业务的网站。例如：`Lighttpd` 有类似的插件`mod_secdownload`来实现此功能，现在服务器配置此模块，设置一个固定用于加密的字符串，比如abcdocker，然后设置一个url前缀，比如/abc/，再设置一个过期时间，比如1小时，然后写一段PHP代码，例如加密字符串和系统时间等通过md5算法生产一个加密字符串，最终获取到的文件的URL连接种会带由一个时间戳和一个加密字符的md5数值，在访问时系统会对这两个数据进行验证。如果时间不在预期的时间段内（如1小时）则失效；如果时间戳符合条件，但是加密的字符串不符合条件也失效，从而达到防盗链的效果。

PHP代码示例如下：

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/7449dy5dyiju7zsrmf5l0g7p/image_1b4t2v8j117ev4vh18nsf1h1dij34.png)

Nginx实现下载防盗链模块

http://nginx.org/en/docs/http/ngx_http_secure_link_module.html

(4)在产品设计上解决盗链方案

产品设计时，处理盗链问题可将计就计，为网络上传的图片添加水印。

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/tdw85yx7io4tj4dcxp3c615i/image_1b4t2vsfjspa2os13dm1sdf84r3h.png)

图片添加版权水印，很多网站一般直接转载图片是为了快捷，但是对于有水印的图片，很多站长是不愿意进行转载的。

(4)Nginx防盗链演示

1.利用referer并且针对扩展名rewrite重定向。

```
 #Preventing hot linking of images and other file typeslocation ~* ^.+\.(jpg|png|swf|flv|rar|zip)$ {    valid_referers none blocked *.abcdocker.org abcdocker.org;    if ($invalid_referer) {        rewrite ^/ http://bbs.abcdocker.org/img/nolink.gif;    }    root html/www;}
```

**提示：**要根据主机公司实际业务（是否有外联的合作），进行域名设置。

针对防盗链中设置进行解释

`jpg` `png` `swf` `flv` `rar` `zip` 表示对`jpg、gif`等zip为后缀的文件实行防盗链处理

`*.abcdocker.org abcdocker.org`表示这个请求可以正常访问上面指定的文件资源

`if{}`中内容的意思是：如果地址不是上面指定的地址就跳转到通过rewrite指定的地址，也可以直接通过retum返回`403`错误

`return 403`为定义的http返回状态码

`rewrite ^/ http://bbs.abcdocker.org/img/nolink.gif;`表示显示一张防盗链图片

`access_log off;`表示不记录访问日志，减轻压力

`expires 3d`指的是所有文件3天的浏览器缓存

**实战模拟演示**

1）假定blog.abcdocker.com是非法盗链的网站域名，先写一个html程序。

```
</span></code></li><li class="L3"><code class="language-o"><span class="pln">123456789</span></code></li><li class="L4"><code class="language-o"><span class="tag">  bgcolor=green>博客我的博客 href="http://oldboy.blog.etiantian.org" target=_blank“>博客地址 src="http://www.abcdocker.com/stu.jpg">  
```

这个非法链接的网站给他用户提供的访问地址是

```
http://blog.abcdocker.com/123.html` 网站里回家再`www.abcdocker.com`网站图片的`stu.jpg
```

Nginx的日志格式为`www.abcdocker.com`，其内容如下

```
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '                       '$status $body_bytes_sent "$http_referer" '                       '"$http_user_agent" "$http_x_forwarded_for"';
```

盗链的图片blog.abcdocker.com访问我们站点时，记录的日志如下：

```
10.0.0.1 - - [30/May/2016:11:13:38 +0800] "GET /stu.jpg HTTP/1.1" 200 68080 "http://blog.abcdocker.com/123.html "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0"
```

可在www.abcdocker.com网站下设置防盗链，Nginx的方法如下：

```
 #Preventing hot linking of images and other file typeslocation ~* ^.+\.(jpg|png|swf|flv|rar|zip)$ {    valid_referers none blocked *.abcdocker.org abcdocker.org;    if ($invalid_referer) {        rewrite ^/ http://bbs.abcdocker.org/img/nolink.gif;    }    root html/www;}
```

**提示：** referers不是*.abcdocker.org的话，就给他一个跳转

**5.为什么要配置错误页面优化显示？**

在网站的运行过程中，可能由于页面不存在或者系统过载等原因，导致网站无法正常响应用于的请求，此时Web服务默认会返回系统默认的错误码，或者很不友好的页面。影响用户体验

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/ouphjg4hquk53r957hcru9cf/image_1b4t36ph5k9t68f1t6b1vkb1qrv3u.png)

对错误代码`404`实行本地页面优雅显示

```
    server {        listen       80;        server_name  www.etiantian.org;        location / {            root   html/www;            index  index.php index.html index.htm;            error_page 404           /404.html#当页面出现404错误时，会跳转404.html页面显示给用户        }
```

提示：

此路径相对于`root html/www;`的

```
 error_page  404              /404.html;  error_page  403  /403.html; 
```

另一种 重定向到一个地址

```
 error_page   404  http://www.abcdocker.com; #error_page  404              /404.html;error_page   404  http://www.abcdocker.com;
```

可以写多行。

```
 error_page   404              /404.html;error_page   500 502 503 504  /50x.html;
```

阿里门户网站天猫的Nginx优雅显示配置案例如下：

```
error_page   500 501 502 503 504 http://err.tmall.com/error2.html;error_page 400 403 404 405 408 410 411 412 413 414 415 http://err.tmall.com/error1.html;
```

#### 6 Nginx站点目录文件及目录权限优化

为了保证网站不遭受木马入侵，所有站点的用户和组都应该为`root`，所有目录权限是`755`；所有文件权限是`644`.设置如下：

```
-rw-r--r--  1 root root      20 May 26 12:04 test_info.phpdrw-r--r--  8 root root    4096 May 29 16:41 uploads
```

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/nl7179rocxu8cuodq8cvkwj9/image_1b4t3apvf1187ap817u81ahs1b4b.png)

可以设置上传只可以`put`不可以`get`，或者使用`location`不允许访问共享服务器的内容，图片服务器禁止访问php|py|sh。这样就算黑客将php木马上传上来也无法进行执行

**集群架构中不同角色的权限具体思路说明**

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/w7l0s0z4sn7d6gpjtk84pbfn/image_1b4t3dafg1bb5186315bt1n2t13c44o.png)

#### 7 Nginx防`爬虫`优化

**1.**`**robots.txt**`**机器人协议介绍**

`Robots`协议（也成为爬虫协议、机器人协议等）的全称是`网络爬虫排除标准`(Robots Exclusin Protocol)网站通过Robots协议告诉引擎那个页面可以抓取，那些页面不能抓取。

**2.机器人协议八卦**

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/47uywtn8hei9cycwd34y8zq4/image_1b4t3f0ct13b32ml33c1ob31rfk55.png)

`2008年9月8日`，淘宝网宣布封杀百度爬虫，百度热痛遵守爬虫协议，因为一旦破坏协议，用户的隐私和利益就无法得到保障。

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/qft17uv4hqp9bo0dyeg0kdsn/image_1b4t3flbb53fhu81kvtm3keko5i.png)

2012年8月。360综合搜索被指违反robots协议

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/6od2u2h2lul7ti3jwb1vuhns/image_1b4t3fv0rov91ilj9j616sotf05v.png)

**3.Nginx防爬虫优化**

我们可以根据客户端的`user-agents`信息，轻松地阻止爬虫取我们的网站防爬虫

范例：阻止下载协议代理

```
 ## Block download agents ##     if ($http_user_agent ~* LWP::Simple|BBBike|wget) {            return 403;     }
```

**说明：**如果用户匹配了if后面的客户端(例如wget)就返回403

**范例：添加内容防止N多爬虫代理访问网站**

```
 if ($http_user_agent ~* "qihoobot|Baiduspider|Googlebot|Googlebot-Mobile|Googlebot-Image|Mediapartners-Google|Adsbot-Google|Yahoo! Slurp China|YoudaoBot|Sosospider|Sogou spider|Sogou web spider|MSNBot") {      return 403; } 
```

测试禁止不同的浏览器软件访问

```
 if ($http_user_agent ~* "Firefox|MSIE") { rewrite ^(.*) http://blog.etiantian.org/$1 permanent;} 如果浏览器为Firefox或者IE就会跳转到http:blog.etiantian.org
```

**提示：**

这里主要用了`$remote_addr`这个函数在记录。

查看更多函数

```
[root@web02 conf]# cat fastcgi_paramsfastcgi_param  QUERY_STRING       $query_string;fastcgi_param  REQUEST_METHOD     $request_method;fastcgi_param  CONTENT_TYPE       $content_type;fastcgi_param  CONTENT_LENGTH     $content_length;fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;fastcgi_param  REQUEST_URI        $request_uri;fastcgi_param  DOCUMENT_URI       $document_uri;fastcgi_param  DOCUMENT_ROOT      $document_root;fastcgi_param  SERVER_PROTOCOL    $server_protocol;fastcgi_param  HTTPS              $https if_not_empty;fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;fastcgi_param  REMOTE_ADDR        $remote_addr;fastcgi_param  REMOTE_PORT        $remote_port;fastcgi_param  SERVER_ADDR        $server_addr;fastcgi_param  SERVER_PORT        $server_port;fastcgi_param  SERVER_NAME        $server_name;# PHP only, required if PHP was built with --enable-force-cgi-redirectfastcgi_param  REDIRECT_STATUS    200;
```

#### 8 利用Nginx限制HTTP的请求方法

HTTP最常用的方法为`GET/POST`，我们可以通过Nginx限制http请求的方法来达到提升服务器安全的目的，

例如，让HTTP只能使用GET、HEAD和POST方法配置如下：

```
 #Only allow these request methods     if ($request_method !~ ^(GET|HEAD|POST)$ ) {         return 501;     }#Do not accept DELETE, SEARCH and other methods
```

设置对应的用户相关权限，这样一旦程序有漏洞，木马就有可能被上传到服务器挂载的对应存储服务器的目录里，虽然我们也做了禁止PHP、SH、PL、PY等扩展名的解析限制，但是还是会遗漏一些我们想不到的可执行文件。对于这种情况，该怎么办捏？事实上，还可以通过限制上传服务器的web服务（可以具体到文件）使用GET方法，来达到防治用户通过上传服务器访问存储内容，让访问存储渠道只能从静态或图片服务器入口进入。例如，在上传服务器上限制HTTP的GET方法的配置如下：

```
 ## Only allow GET request methods ##     if ($request_method ~* ^(GET)$ ) {         return 501;     }
```

提示：还可以加一层`location`更具体的限制文件名

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/teriyodegw86h8irli5u01m0/image_1b4t3q9omg2k1o4hv3e1i8b1jb36c.png)

#### 9 使用`CDN`做网站内容加速

**1.什么是CDN？**

CDN的全称是`Content Delivery Network` 中文意思是内容分发网络。

通过现有的Internet中增加一层新的网络架构，将网站的内容发布到最接近用户的cache服务器内，通过智能DNS负载均衡技术，判断用户的来源，让用户就近使用和服务器相同线路的带宽访问cache服务器取得所需的内容。

例如：天津网通用户访问天津网通Cache服务器上的内容，北京电信访问北京电信Cache服务器上的内容。这样可以减少数据在网络上传输的事件，提高访问速度。

CDN是一套全国或全球的分布式缓存集群，其实质是通过智能DNS判断用户的来源地域以及上网线路，为用户选择一个最接近用户地狱以及和用户上网线路相同的服务器节点，因为地狱近，切线路相同，所以，可以大幅度提升浏览网站的体验。

**CDN的价值**

1、为架设网站的企业省钱。

2、提升企业网站的用户访问体验（相同线路，相同地域，内存访问）。

3、可以阻挡大部分流量攻击，例如：DDOS攻击

更多CDN介绍请查看本网相关文章

#### 10 Nginx程序架构优化

**1.为网站程序解耦**

解耦是开发人员中流行的一个名词，简单地说就是把一堆程序嗲吗按照业务用途分开，然后提供服务，例如：注册登录、上传、下载、订单支付等都应该是独立的程序服务，只不过在客户端看来是一个整体而已。如果中小公司做不到上述细致的解耦，最起码让下面的几个程序模块独立。

**1.网站页面服务**

**2.图片附件及下载服务。**

**3.上传图片服务**

上述三者的功能尽量分离。分离的最佳方式是分别使用独立的服务器（需要改动程序）如果程序实在不好改，次选方案是在前端负载均衡器`haproxy/nginx`上，根据URI设置

**使用普通用户启动Nginx（监牢模式）**

1.为什么要让Nginx服务使用普通用户

默认情况下，Nginx的`Master`进程使用的是`root`用户，`Worker`进程使用的是`Nginx`指定的普通用户，使用root用户跑Nginx的Master进程由两个最大的问题：

▲ 管理权限必须是root，这就使得最小化分配权限原则遇到难题

▲使用root跑Nginx服务，一旦网站出现漏洞，用户就很容易获得服务器root权限

```
[root@web02 ~]# ps -ef|grep nginxroot       2155      1  0 03:43 ?        00:00:00 nginx: master process /application/nginx/sbin/nginxwww        2156   2155  0 03:43 ?        00:00:01 nginx: worker process        www        3047   2155  0 06:17 ?        00:00:00 nginx: worker process        www        3051   2155  0 06:17 ?        00:00:00 nginx: worker process        www        3435   2155  0 11:13 ?        00:00:00 nginx: worker process
```

2.给Nginx服务降权解决方案

(1) 给Nginx服务降权，用inca用户跑Nginx服务，给开发及运维设置普通账号，只要和inca同组即可管理Nginx，该方案解决了Nginx管理问题，防止root分配权限过大。

(2) 开发人员使用普通账户即可管理Nginx服务以及站点下的程序和日志

(3) 采取项目负责制，即谁负载项目维护处了问题就是谁负责。

3.实时Nginx降权方案

```
[root@web02 ~]# useradd inca[root@web02 ~]# su - inca[inca@web02 ~]$ pwd/home/inca[inca@web02 ~]$ mkdir conf logs www[inca@web02 ~]$ cp /application/nginx/conf/mime.types ~/conf/[inca@web02 ~]$ echo inca >www/index.html [inca@web01 ~]$ cat conf/nginx.conf worker_processes  4;worker_cpu_affinity 0001 0010 0100 1000;worker_rlimit_nofile 65535;error_log  /home/inca/logs/error.log;user inca inca;pid        /home/inca/logs/nginx.pid;events {    use epoll;    worker_connections  10240;}http {    include       mime.types;    default_type  application/octet-stream;    sendfile        on;    keepalive_timeout  65;     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '                      '$status $body_bytes_sent "$http_referer" '                      '"$http_user_agent" "$http_x_forwarded_for"';     #web.fei fa daolian..............    server {        listen       8080;        server_name  www.etiantian.org;        root   /home/inca/www;        location / {            index  index.php index.html index.htm;                }         access_log  /home/inca/logs/web_blog_access.log  main;           }}
```

提示，需要关闭root权限的nginx，否则会报错

```
[root@web02 ~]# /application/nginx/sbin/nginx -s stop[root@web02 ~]# lsof -i:80
```

切换用户，启动`Nginx`

```
[root@web02 ~]# su - inca[inca@web02 ~]$  /application/nginx/sbin/nginx -c /home/inca/conf/nginx.conf &>/dev/null &[1] 3926[inca@web02 ~]$ lsof -i:80[1]+  Exit 1                  /application/nginx/sbin/nginx -c /home/inca/conf/nginx.conf &>/dev/null
```

**本解决方案的优点如下：**

1.给Nginx服务降权，让网站更安全

2.按用户设置站点权限，使站点更安全（无需虚拟化隔离）

3.开发不需要用root即可完整管理服务及站点

4.可实现对责任划分，网络问题属于运维的责任，打开不就是开发责任或共同承担

**控制Nginx**`**并发**`**连接数**

`nginx_http_limit_conn_module`这个模块用于限制每个定义的key值的连接数，特别是单IP的连接数。

不是所有的连接数都会被计数。一个符合要求的连接是整个请求头已经被读取的连接。

控制Nginx并发连接数量参数的说明如下：

```
limit_conn_zone参数：语法：limit_conn_zone key zone=name:size;上下文:http用于设置共享内存区域，key可以是字符串，nginx自有变量或前两个组合，如$binary_remote_addr、$server_name。name为内存区域的名称，size为内存区域的大小。limit_conn参数：语法：limit_conn zone number;上下文：http、server、location
```

配置文件如下：

```
[root@oldboy ~]# cat /application/nginx/conf/nginx.confworker_processes  1;events {    worker_connections  1024;}http {    include       mime.types;    default_type  application/octet-stream;    sendfile        on;    keepalive_timeout  65;     limit_conn_zone $binary_remote_addr zone=addr:10m;     server {        listen       80;        server_name   www.etiantian.org;        location / {            root   html;            index  index.html index.htm;            limit_conn addr 1; #<==限制单IP的并发连接为1        }    }}
```

还可以设置某个目录单IP并发连接数

```
         location /download/ {            limit_conn addr 1;        }
```

在客户端使用Apache的ab测试工具进行测试

执行`ab -c 1 -n 10 http://10.0.0.3`进行测试

注意：-c并发数、-n请求总数，`10.0.0.3nginx`的IP地址

![[Nginx] – 安全优化 – 配置文件优化 [二]](https://images.ukx.cn/abcdocker/2jplm6tjyql8uw4y995lpwn4/image_1b4t44gou1vvj1t4tjv01lcb8116p.png)

#### 11 控制客户端请求Nginx的速率

`ngx_http_limit_req_module`模块用于限制每个IP访问定义key的请求速率。

**limit_req_zone参数说明如下：**

语法：`limit_req_zonekey zone=name:size rate=rate;`

用于设置共享内存区域，key可以是字符串、Nginx自有变量或前两个组合，如`$binary_remote_addr` `name`为内存区域的名称，`size`为内存区域的大小，`rate`为速率，单位为`r/s` 每秒一个请求。

```
[root@oldboy ~]# cat /application/nginx/conf/nginx.conf         worker_processes  1;events {    worker_connections  1024;}http {    include       mime.types;    default_type  application/octet-stream;    sendfile        on;    keepalive_timeout  65;    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;#<==以请求的客户端IP作为key值，内存区域命名为one，分配10m内存空间，访问速率限制为1秒1次请求(request)    server {        listen       80;        server_name   www.etiantian.org;        location / {            root   html;            index  index.html index.htm;            limit_req zone=one burst=5; #<==使用前面定义的名为one的内存空间，队列值为5，即可以有5个请求排队等待。        }    }}
```
