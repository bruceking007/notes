## certbot

#### 安装certbot

```
yum install -y certbot python-certbot-nginx

```

#### 安装certbot和certbot nginx plugin

```
sudo apt install certbot
sudo apt install python3-certbot-nginx
```



#### 申请证书

```
certbot certonly -d "api.9954q4oh34.top" --manual --preferred-challenges dns-01

--
sudo certbot --non-interactive --redirect --agree-tos --nginx -d password.zahui.fan -m captain@zahui.fan
```





#### 查看证书信息

```
certbot certificates
```





#### 申请成功后

[配置文件](https://eff-certbot.readthedocs.io/en/stable/using.html#configuration-file)
配置文件: /etc/letsencrypt/renewal/
证书文件源目录: /etc/letsencrypt/archive/
证书文件映射目录: /etc/letsencrypt/live/



#### 删除证书

```
certbot delete --cert-name www.brilliantcode.net
```



#### 回收证书

```shell
certbot revoKe --cert-name www.brilliantcode.net #交互式
certbot -n revoKe --cert-name www.brilliantcode.net  #非交互式 -n
```

循环

```
#!/bin/bash
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

if [ ! -d /tmp/nginx-conf-bak ];then mkdir /tmp/nginx-conf-bak;fi
while true
do
        echoGreen "----------> 分割线 <----------"
        read -p 'please input revoke domain:' domain
        echoYellow "---> 备份配置文件start"
        fileName=$(cd /etc/nginx/conf.d && ls -l *$domain*|awk '{print $NF}')
        cd /etc/nginx/conf.d && mv -v ${fileName} /tmp/nginx-conf-bak/
        echoYellow "---> 备份配置文件end"
        nginx -t
        find /etc/letsencrypt/ -name *${domain}* 
        echoYellow "---> revoke start"
        certbot revoke --cert-name ${domain}
        echoYellow "---> revoke end"
        find /etc/letsencrypt/ -name *${domain}* 
done
```

非循环

```
#!/bin/bash
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

domain=$1

if [ ! -d /tmp/nginx-conf-bak ];then mkdir /tmp/nginx-conf-bak;fi
echoGreen "----------> 分割线 <----------"
echoYellow "---> 备份配置文件start"
fileName=$(cd /etc/nginx/conf.d && ls -l *$domain*|awk '{print $NF}')
cd /etc/nginx/conf.d && mv -v ${fileName} /tmp/nginx-conf-bak/
echoYellow "---> 备份配置文件end"

echoYellow "---> 语法检查start"
nginx -t
echoYellow "---> 语法检查end"

echoYellow "---> 查找证书目录start"
find /etc/letsencrypt/ -name ${domain} 
echoYellow "---> 查找证书目录end"

echoYellow "---> revoke start"
certbot -n revoke --cert-name ${domain}
echoYellow "---> revoke end"

find /etc/letsencrypt/ -name ${domain}
```



#### 参考文档 

```
https://blog.csdn.net/qq_50573146/article/details/126697050
```

[Certbot免费的HTTPS证书](https://blog.csdn.net/qq_50573146/article/details/126697050)

[Certbot命令行工具使用说明](https://www.cnblogs.com/dancesir/p/14329327.html)

#### 报错问题

https://forum.linuxconfig.org/t/the-requested-nginx-plugin-does-not-appear-to-be-installed-letsencrypt/4525





##### 出现无法申请证书或者证书失效（浏览器打开提示引用的是另一个域名的证书）

```
Certbot failed to authenticate some domains (authenticator: nginx). The Certificate Authority reported these problems:
Domain: m3.ujdg9zmdxy6x.top
Type:   connection
Detail: 16.163.235.6: Fetching http://m3.ujdg9zmdxy6x.top/.well-known/acme-challenge/fhlgVgm8w3FnuQKrrvIXUYAncx_N82Ynwo3mDJSyhIs: Error getting validation data

Hint: The Certificate Authority failed to verify the temporary nginx configuration changes made by Certbot. Ensure the listed domains point to this ngin
```

查看nginx报错日志，出现如下报错

```
2023/10/24 10:58:18 [emerg] 16923#16923: open() "/var/log/nginx/xxx1.top.error.log" failed (24: Too many open files)
2023/10/24 10:58:28 [emerg] 16923#16923: open() "/var/log/nginx/xxx2.top.error.log" failed (24: Too many open files)
```

解决办法

```
https://blog.csdn.net/u011635437/article/details/113620068             #Nginx报Too Many Open Files总结
https://halysl.github.io/2020/11/18/systemd-service%E9%85%8D%E7%BD%AEulimit%E9%99%90%E5%88%B6/ #systemd service 配置 ulimit 限制
```

