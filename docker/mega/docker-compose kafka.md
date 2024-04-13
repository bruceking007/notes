```yaml
version: "3"
services:
  zookeeper:
    image: 'bitnami/zookeeper:latest'
    ports:
      - '2181:2181'
    environment:
      # 匿名登录--必须开启
      - ALLOW_ANONYMOUS_LOGIN=yes
    #volumes:
      #- ./zookeeper:/bitnami/zookeeper
  # 该镜像具体配置参考 https://github.com/bitnami/bitnami-docker-kafka/blob/master/README.md
  kafka:
    image: 'bitnami/kafka:latest'
    ports:
      - '9092:9092'
      #- '9999:9999'
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_CFG_LISTENERS=PLAINTEXT://:9092
      # 客户端访问地址，更换成自己的
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://:9092
      - KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181
      # 允许使用PLAINTEXT协议(镜像中默认为关闭,需要手动开启)
      - ALLOW_PLAINTEXT_LISTENER=yes
      # 开启自动创建 topic 功能便于测试
      #- KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true
      # 全局消息过期时间 6 小时(测试时可以设置短一点)
      #- KAFKA_CFG_LOG_RETENTION_HOURS=6
      # 开启JMX监控
      #- JMX_PORT=9999
    #volumes:
      #- ./kafka:/bitnami/kafka
    depends_on:
      - zookeeper
```

