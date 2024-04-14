docker-compose.yml文件

```yaml
version: '3'
services:
    geoipupdate:
      container_name: geoipupdate
      hostname: geoipupdate
      image: maxmindinc/geoipupdate:latest
      restart: always
      environment:
        GEOIPUPDATE_ACCOUNT_ID: 890147
        GEOIPUPDATE_LICENSE_KEY: 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
        GEOIPUPDATE_EDITION_IDS: GeoLite2-ASN GeoLite2-City GeoLite2-Country
        GEOIPUPDATE_FREQUENCY: 24 #多久执行一次,单位小时
        GEOIPUPDATE_PRESERVE_FILE_TIMES: 1  #是否保留文件原始时间
      volumes:
        - /etc/localtime:/etc/localtime:ro
        - /etc/logstash/GeoIP:/usr/share/GeoIP
```

https://hub.docker.com/r/maxmindinc/geoipupdate

https://www.maxmind.com/en/accounts/890147/geoip/downloads



```
Docker 镜像是通过环境变量配置的。需要以下变量：

GEOIPUPDATE_ACCOUNT_ID- 您的 MaxMind 帐户 ID。
GEOIPUPDATE_LICENSE_KEY- 您的 MaxMind 许可证密钥（区分大小写）。
GEOIPUPDATE_EDITION_IDS- 以空格分隔的数据库版本 ID 列表。版本 ID 可能由字母、数字和破折号组成。例如， GeoIP2-City 106将下载 GeoIP2 城市数据库 ( GeoIP2-City) 和 GeoIP Legacy Country 数据库 ( 106)。
以下是可选的：

GEOIPUPDATE_FREQUENCY- 运行之间的小时数geoipupdate。如果未设置或设置为0，geoipupdate将运行一次并退出。
GEOIPUPDATE_HOST- 要使用的服务器的主机名。默认为 updates.maxmind.com.
GEOIPUPDATE_PROXY- 代理主机名或 IP 地址。您可以选择指定端口号，例如 127.0.0.1:8888。如果未指定端口号，则将使用 1080。
GEOIPUPDATE_PROXY_USER_PASSWORD- 代理用户名和密码，以冒号分隔。例如，username:password.
GEOIPUPDATE_PRESERVE_FILE_TIMES- 是否保留从服务器下载的文件的修改时间。该选项是0或1。默认为0.
GEOIPUPDATE_VERBOSE- 启用详细模式。打印出所采取的步骤 geoipupdate。
环境变量可以放置在一个文件中，每行一个，并与标志一起传入--env-file。或者，您可以将它们与标志一起单独传递-e。
```



```yaml
# GeoIP.conf file for `geoipupdate` program, for versions >= 3.1.1.
# Used to update GeoIP databases from https://www.maxmind.com.
# For more information about this config file, visit the docs at
# https://dev.maxmind.com/geoip/updating-databases.

# `AccountID` is from your MaxMind account.
AccountID 890147

# `LicenseKey` is from your MaxMind account
LicenseKey 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

# `EditionIDs` is from your MaxMind account.
EditionIDs GeoLite2-ASN GeoLite2-City GeoLite2-Country
```



