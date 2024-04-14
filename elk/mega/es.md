### 1、nginx代理es

```
server {
    listen 9200;
    #status_zone elasticsearch;
    access_log  /var/log/nginx/es.access.log main;
    location / {
        proxy_pass http://elasticsearch_servers;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        #proxy_cache elasticsearch;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_connect_timeout 5s;
        proxy_read_timeout 10s;
        #health_check interval=5s fails=1 passes=1 uri=/ match=statusok;
    }
}

upstream elasticsearch_servers {
    #zone elasticsearch_servers 64K;
    server 192.168.0.31:9200;
}
```

https://www.ttlsa.com/nginx/nginx-elasticsearch/

https://www.volcengine.com/theme/7091404-R-7-1