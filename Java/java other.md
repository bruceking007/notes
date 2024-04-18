#### 查看jar启动端口

```shell
ss -tunlp|grep `jps -mlv|grep .jar|awk '{print $1}'`|awk '{print $5}'|awk -F ":" '{print $NF}'
```

