
ip route add 10.10.0.0/24 via 192.168.2.92 dev eth0


如果不安装实现虚拟局域网的软件

就需要配置路由规则

上面的命令就是，访问 10.10.0.0/24网段的流量，经过192.168.2.92这个网关流出


192.168.2.92 这个是nginx负载均衡服务器，只需要在这个服务器上安装虚拟局域网软件即可

我在华为云的生产环境中都执行了一下这个添加路由的命令



#### 1、新添加日志步骤

- 华为云安全组开放端口
- 华为云kibana新创建租户，角色，用户，并把角色绑定租户和用户
- 华为云kafka创建新Topic
- logstash 配置文件新添加Tipic来源
- 安装filebeat并配置filebeat  https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.2-x86_64.rpm

