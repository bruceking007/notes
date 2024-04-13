#### 将 docker-compose 升级到最新版本

[在 GitHub 的发布页面上](https://github.com/docker/compose/releases)找到 *最新版本* ，或者通过 curl API并使用or从响应中[提取](https://www.jb51.cc/tag/tiqu/)版本：grep``jq

 

```shell
 \# curl + grep
  VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
  
  \# curl + jq
  VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
```



*下载* 到您最喜欢的 $PATH 可访问位置并设置权限： 

```shell
  DESTINATION=/usr/local/bin/docker-compose
  sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
  sudo chmod 755 $DESTINATION
```

升级脚本

```shell
\#!/bin/bash
\#获取最新版本
while true;do
  if ! VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d');then
    echo "未获取到最新版本，将继续尝试获取，请耐心等待！" 
  else
    echo "获取到最新版本！版本号为：${VERSION}"
    break
  fi
done


\#服务器需要存放的地方
ARRDEST=(/usr/local/bin/docker-compose /usr/bin/docker-compose)

\#下载最新版本的内容
while true;do

  if ! curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o docker-compose;then
    echo "未下载到最新版本，将继续尝试下载，请耐心等待！" 
  else
    echo "下载到最新版本！"
    break
  fi
done


\#获取下载的sha256值
dwsha256=$(sha256sum docker-compose|awk '{print $1}')

\#获取官网的sha256值
while true;do

  if ! orisha256=$(curl -Ls https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-linux-x86_64.sha256|awk '{print $1}');then
    echo "未获取到官网的sha256值,将继续尝试获取，请耐心等待！" 
  else
    echo "获取到官网的sha256值! sha256值为: ${orisha256}"
    break
  fi
done

\#判断下载的是否和官网的一致，一致则继续下一步，否则退出
if [ "$dwsha256" = "$orisha256" ];then
  for DESTINATION in "${ARRDEST[@]}"
  do
      \cp docker-compose $DESTINATION 
      chmod 755 $DESTINATION
      $DESTINATION -v
  done
else
  exit 0
fi
```

