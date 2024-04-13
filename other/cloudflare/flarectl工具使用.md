#### 前提

```
export CF_API_EMAIL='xxx@gmail.com'
export CF_API_KEY='xxx'
```



#### 添加域名

```
flarectl zone create  --zone=wyq3757rib.top --jumpstart=true

flarectl zone create --account-id=122388db36cdcaa33b97fd5ea2117b76 --zone=wyq3757rib.top --jumpstart=true
```



#### 查询dns解析记录

```
flarectl dns list --zone=z7h8lrlmli.top
```



#### 查询nameserver

```
flarectl zone info --zone=z7h8lrlmli.top
```



#### 更改dns解析记录

```
id=$(flarectl dns list --zone=z7h8lrlmli.top|grep new|awk '{print $1}')
flarectl dns update --zone=z7h8lrlmli.top --id=$id --name=new --content=1.1.1.3
```





https://www.80ii.cn/index.php/archives/cloudflare.html

https://developers.cloudflare.com/fundamentals/setup/add-multiple-sites-automation/

https://developers.cloudflare.com/api/operations/zones-post