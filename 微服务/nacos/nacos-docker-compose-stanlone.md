##### 1、docker部署单机nacos

###### 1.1 创建utf8数据库（只支持utf8）

```
#获取sql文件
docker cp nacos:/home/nacos/conf/mysql-schema.sql /tmp/
```

```sql
CREATE DATABASE IF NOT EXISTS nacos_config DEFAULT CHARSET utf8 COLLATE utf8_general_ci
```

###### 1.2 yaml配置文件

```yaml
version: '3'

services:
  nacos:
    image: nacos/nacos-server:v2.2.3
    restart: always
    container_name: nacos
    ports:
      - 8848:8848
    environment:
      TZ: Asia/Shanghai
      MODE: standalone
      SPRING_DATASOURCE_PLATFORM: mysql
      MYSQL_SERVICE_HOST: 172.26.143.232
      MYSQL_SERVICE_PORT: 53306
      MYSQL_SERVICE_USER: root
      MYSQL_SERVICE_PASSWORD: xC5HJdSxjJjwkE46
      MYSQL_SERVICE_DB_NAME: nacos
      MYSQL_SERVICE_DB_PARAM: characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
      NACOS_AUTH_IDENTITY_KEY: serverIdentity
      NACOS_AUTH_IDENTITY_VALUE: security
      #NACOS_AUTH_TOKEN: SecretKey012345678901234567890123456789012345678901234567890123456789
      NACOS_AUTH_TOKEN: dDI1YmZCR3VxMjZwR0FLZ0xWR0R3YkFmeWdIVU1QNGg=
      NACOS_AUTH_ENABLE: true
    volumes:
      #- ./conf/application.properties:/home/nacos/conf/application.properties
      - ./logs:/home/nacos/logs
      - ./plugins/:/home/nacos/plugins
```

https://hub.docker.com/r/nacos/nacos-server



##### 2、nginx代理nacos

```
server {
    server_name nacos.ibgx.top;
    # client_max_body_size 5M;
    charset UTF-8;
    autoindex off;

    access_log  /var/log/nginx/nacos.ibgx.top.access.log main;
    error_log  /var/log/nginx/nacos.ibgx.top.error.log;
    
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }

    location  / {
       proxy_set_header Host $http_host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header REMOTE-HOST $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_pass http://127.0.0.1:8848;
    }



    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/nacos.ibgx.top/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/nacos.ibgx.top/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = nacos.ibgx.top) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name nacos.ibgx.top;
    listen 80;
    return 404; # managed by Certbot
}
```

初始用户名：nacos

初始密码：nacos



##### 参考文档

https://nacos.io/zh-cn/docs/deployment.html  

https://nacos.io/zh-cn/docs/cluster-mode-quick-start.html





##### 集群

https://juejin.cn/post/7036620882982207495

https://zhuanlan.zhihu.com/p/394967818

https://blog.csdn.net/wtl1992/article/details/125949989

https://www.cnblogs.com/hahaha111122222/p/17395301.html

https://www.chenxie.net/archives/2679.html

https://vlambda.com/wz_7iJFw9uYNBy.html
