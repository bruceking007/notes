

### 导航



- [不死鸟发布](https://dalao.ru/)

  

### 综合



- [二丫讲梵](https://wiki.eryajf.net/)
- [中文独立博客列表](https://github.com/eryajf/chinese-independent-blogs)

- [GitHub中文排行榜](https://github.com/eryajf/GitHub-Chinese-Top-Charts)

- [安志合的学习博客]([https://chegva.com](https://chegva.com/))

- [杂烩饭](https://zahui.fan/)

- [运维小弟](https://doc.srebro.cn/)

- [杜老师说](https://dusays.com/)

- [崔亮的博客](https://www.cuiliangblog.cn/)

- [杂烩饭](https://zahui.fan/)

- [山山仙人的博客](https://www.ssgeek.com/page/8/)

### Jenkins

- [Jenkins中自由风格回滚方案的最佳实践](https://wiki.eryajf.net/pages/3508.html#_2-%E8%87%AA%E7%94%B1%E9%A3%8E%E6%A0%BC%E5%8D%95%E6%9C%BA%E9%83%A8%E7%BD%B2%E5%9B%9E%E6%BB%9A%E7%A4%BA%E4%BE%8B)
- [Jenkins中pipeline风格回滚方案的最佳实践](https://wiki.eryajf.net/pages/3510.html#_1-%E5%9F%BA%E4%BA%8Epipeline%E7%9A%84%E5%AE%9A%E5%88%B6%E5%8C%96%E5%8D%95%E6%9C%BA%E7%89%88%E6%9C%AC%E5%8F%91%E5%B8%83%E5%9B%9E%E6%BB%9A%E9%85%8D%E7%BD%AE%E7%AE%A1%E7%90%86)

- [Jenkins构建完显示构建用户和构建分支](https://www.iyunw.cn/archives/jenkins-gou-jian-wan-xian-shi-gou-jian-yong-hu-he-gou-jian-fen-zhi/)
- [使用Jenkins发布Android应用](https://www.coolops.cn/archives/shi-yong-jenkins-fa-bu-android-ying-yong)
- [Jenkins - DevOps](https://notes.youngkbt.cn/jenkins/devops/#devops-%E4%BB%8B%E7%BB%8D)

### 软件源

[Linux 一键更换国内软件源 ](https://github.com/SuperManito/LinuxMirrors)  https://linuxmirrors.cn/use/



### 安全

[LinuxCheck](https://github.com/al0ne/LinuxCheck)

[Web安全学习笔记](https://websec.readthedocs.io/zh/latest/index.html)



### linux

- [linux常用alias](https://chegva.com/2616.html)
- [Linux运维之回收站篇](https://chegva.com/331.html)

- [将 rm 命令改造成 mv 到指定的目录](https://dusays.com/58/)

```shell
alias rm=trash
alias rml='ls /tmp/trash/'
alias urm=untrash
alias crm=cleantrash
trash()
{
	mv $@ /tmp/trash/
}
untrash()
{
	mv /tmp/trash/$@ ./
}
cleartrash()
{
	read -p "clean sure?[n]" confirm
	[ $confirm == 'y' ] || [ $confirm == 'Y' ] && /bin/rm -rf /tmp/trash/*  
}
```

在原有基础上增加查看、恢复、清空功能，rml 可直接查看回收站的文件，urm 加文件名称可将文件恢复到当前目录中，crm 可清空回收站的所有文件，并需要输入 y 确认。

- [CentOS7 的内核优化](https://dusays.com/19/)

- [24 个常用的 iptables 规则](https://dusays.com/91/)

  

### 工具

- [实用高效的 Chrome 插件推荐](https://chegva.com/3472.html)
- [curl实用技巧](https://chegva.com/2975.html)
- [开源推荐 - CoDo开源一站式DevOps平台](https://github.com/opendevops-cn)
- [certbot](https://commandnotfound.cn/linux/1/484/certbot-%E5%91%BD%E4%BB%A4)
- oh-my-zsh
  - [oh-my-zsh详解](https://commandnotfound.cn/linux/1/151/oh-my-zsh)
  - [zsh 工具详解](https://commandnotfound.cn/linux/1/150/zsh-%E5%B7%A5%E5%85%B7)
  - [oh-my-zsh,最好用的 shell，没有之一](https://learnku.com/articles/32793?order_by=vote_count&)
  - [oh-my-zsh 安装必用插件](https://cloud.tencent.com/developer/article/2231632?areaId=106001)


----------



[domain-admin](https://github.com/mouday/domain-admin)   域名过期管理  https://domain-admin.readthedocs.io/zh_CN/latest/manual/install.html

```yaml
version: '3'
services:
    domain-admin:
      container_name: domain-admin
      hostname: domain-admin
      image: mouday/domain-admin:latest
      restart: always
      volumes:
        - /etc/localtime:/etc/localtime:ro
        - ./database:/app/database
        - ./logs:/app/logs
      ports:
        - 8000:8000
```

---------

[LocalSend：免费文件传输工具，支持全平台](https://www.51cto.com/article/756856.html)   https://localsend.org/#/download

[运维18weapons](https://github.com/WinFoot/18weapons)

##### java

- [Java 应用诊断利器Arthas](https://arthas.aliyun.com/)
- [你要偷偷学会排查线上CPU飙高的问题，然后惊艳所有人！](https://www.51cto.com/article/654778.html)



##### 时间工具

- [优效日历](https://www.youxiao.cn/)
- [翻页时钟](https://www.flitik.com/?from=windows)



##### 截图/滚动截图

[好用的Chrome截图扩展推荐](https://www.v1tx.com/post/best-chrome-screenshot-extensions/)

- GoFullPage

- Nimbus Capture  （best可截取区域滚动截屏，也有windows客户端）

- Fireshot

- Awesome Screenshot （也可用）

- Eagle



##### chagpt

[ChatGPT一键私有部署](https://blog.csdn.net/qq_16027093/article/details/130581563?spm=1001.2100.3001.7377&utm_medium=distribute.pc_feed_blog_category.none-task-blog-classify_tag-1-130581563-null-null.nonecase&depth_1-utm_source=distribute.pc_feed_blog_category.none-task-blog-classify_tag-1-130581563-null-null.nonecase)



##### 常用在线工具



|                                    | [网页在线工具汇总](https://iui.su/1492/)     | [企业查询](https://dingtalk.com/qidian/)         |
| ---------------------------------- | -------------------------------------------- | ------------------------------------------------ |
| [IP查询](https://ip.skk.moe/)      | [在线影视](https://iui.su/531/)              | [匿名分享](https://paste.fastmirror.net/)        |
| [开发者备忘](https://quickref.cn/) | [打字练习](https://www.eletypes.com/)        | [免费文件存储分享服务汇总](https://iui.su/1253/) |
|                                    | [Windows 应用软件下载](https://iui.su/3798/) |                                                  |



##### 安卓Apk应用下载

https://iui.su/3277/

| [VXAT](https://www.vxat.com/Android.html) | [亿破姐](https://www.ypojie.com/app)                         | [423DOWN](https://www.423down.com/apk/)          | [52 破解](https://www.52pojie.cn/forum.php?mod=forumdisplay&fid=16&filter=typeid&typeid=232) |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------ | ------------------------------------------------------------ |
| [翻应用](https://www.iapps.me/?iui.su)    | [枫音应用](https://www.fy6b.com/category/all/android?iui.su) | [异星软件空间](https://www.yxssp.com/os/android) | [果核剥壳](https://www.ghxi.com/category/all/android)        |
| [NITE07](https://www.nite07.com/)         | [发烧友绿软](https://fsylr.com/softs)                        | [鸭先知](https://www.yxzhi.com/android)          | [真下载](https://www.zhenxz.com/new/0_1.html)                |

文件传输

| [文件传输助手](https://fast.uc.cn/) | [虫洞文件传输](https://wormhole.app/)   只能保留24小时 临时传输用 | [钛盘](https://www.tmp.link/) |
| ----------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| [空投快传](https://airportal.cn/)   |                                                              |                               |
|                                     |                                                              |                               |
|                                     |                                                              |                               |



##### 安卓应用市场展开目录

###### **第三方安卓应用分享平台**

- [奇妙应用.apk](https://lanzoui.com/s/MagicalApp) 邀请码：`iui.su`
- [AppShare.apk](https://lanzoui.com/ibzu614fkt7c) 官网：https://appshare.muge.info/
- [酷玩社区.apk](https://lanzoui.com/imQQ90zqwkih) 官网：http://ikuwan.net/
- [全球 apk 分享社区.apk](http://downurl.apkstore.club/android/apkssr_web.html) 官网：http://tapkshare.club/

###### **F-Droid**

收录各类开源软件的 Android 应用商店，如失效可访问 [F-Droid 官网](https://f-droid.org/zh_Hans/)下载

[ **F-Droid 下载**](https://www.123pan.com/s/ZAzA-xRuwh.html)

F-Droid 国内下载较慢，可使用清华大学或南京大学提供的镜像来加速，首先安装 F-Droid，然后手机浏览器访问[南京大学镜像链接](https://mirror.nju.edu.cn/fdroid/repo/)或[清华大学镜像链接](https://mirrors.tuna.tsinghua.edu.cn/fdroid/repo/)，用 F-Droid 客户端打开。如果对镜像速度不满意，可以选择更多的镜像：[F-Droid 校园网联合镜像](https://help.mirrors.cernet.edu.cn/fdroid/)

如不清楚使用方法，可以看少数派上的 [F-Droid 使用指南](https://sspai.com/post/63647)

###### **第三方 apk 下载站**

- [softmany](https://support.qq.com/products/57688/link-jump?jump=https://softmany.com/cn/?iui.su)

**安卓电视 / 盒子 TV / 手机直播应用合集**

[TVBox 安卓盒子影视 app](https://iui.su/175/)、[分享者 / 盒子应用分享](https://www.sharerw.com/a/ziyuan/)

**安卓玩机资源合集**

[http://wanji.jamcz.com](http://wanji.jamcz.com/)



##### Typora 



插件

[Typora Plugin](https://github.com/obgnail/typora_plugin)



##### 科学上网

[clash汉化](https://github.com/Z-Siqi/Clash-for-Windows_Chinese)





### shell

- [简洁的脚本编写规范](https://blog.ops-coffee.cn/s/drt44kkzaeaesjhshsb0vg)
- [一键化打造 Vim IDE 环境](https://github.com/meetbill/Vim)

- [usage](https://www.diskinternals.com/linux-reader/shell-script-usage/)

- [快速释放内存脚本](https://dusays.com/89/)



### tomcat

- [Tomcat环境部署](https://www.ssgeek.com/post/tomcat-huan-jing-bu-shu/)
- [Tomcat进阶操作](https://www.ssgeek.com/post/tomcat-jin-jie-cao-zuo/)

- [Tomcat调优](https://www.ssgeek.com/post/tomcat-diao-you-bu-ding-qi-geng-xin/)

-------



### ms

[运维工程师面试总结(含答案)](https://www.cuiliangblog.cn/detail/article/2)

[linux运维工程师面试题总结](https://www.cuiliangblog.cn/detail/article/1)

[运维题库](http://www.yunweipai.com/tiku)

[运维经典面试题合集](https://fang.readthedocs.io/zh-cn/latest/%E8%BF%90%E7%BB%B4%E4%BA%BA%E7%94%9F/%E8%BF%90%E7%BB%B4%E7%BB%8F%E5%85%B8%E9%9D%A2%E8%AF%95%E9%A2%98%E5%90%88%E9%9B%86.html)

[运维面试相关内容](https://cn.aliyun.com/sswb/553775.html?from_alibabacloud=)

------------



### docker

[Docker 限制 CPU 内存使用](https://dusays.com/497/)

```shell
--memory=VALUE：
内存限制，最小值 6M。

--oom-kill-disable
默认情况下 OOM 错误发生时，主机会杀死容器进程来获取更多内存。使用该选项可以避免容器进程被杀死，但是应该在设置了--memory=VALUE 参数之后才能使用该选项，不然不会限制容器内存使用，却禁止主机杀死容器的进程，出现 OOM 错误时，系统会杀死主机进程来获取内存。
```



#### [Dockerfile](https://www.peterjxl.com/Docker/Dockerfile/)

##### ENTRYPOINT

ENTRYPOINT可以和CMD一起用，一般是变参才会使用 CMD ，这里的 CMD 等于是在给 ENTRYPOINT 传参。

当指定了ENTRYPOINT后，CMD的含义就发生了变化，不再是直接运行其命令而是将CMD的内容作为参数传递给ENTRYPOINT指令，他两个组合会变成 `<ENTRYPOINT> "<CMD>"`

案例如下：假设已通过 Dockerfile 构建了 nginx:test 镜像：

```yaml
FROM nginx;

ENTRYPOINT ["nginx", "-c"] # 定参
CMD ["/etc/nginx/nginx.conf"] # 变参
```

| 是否传参         | 按照dockerfile编写执行         | 传参运行                                     |
| ---------------- | ------------------------------ | -------------------------------------------- |
| Docker命令       | docker run nginx:test          | docker run nginx:test -c /etc/nginx/new.conf |
| 衍生出的实际命令 | nginx -c /etc/nginx/nginx.conf | nginx -c /etc/nginx/new.conf                 |

如果传参运行，相当于用自己传入的配置，覆盖Dockerfile中的默认配置。

‍

优点：在执行docker run的时候可以指定 ENTRYPOINT 运行所需的参数。

注意：如果 Dockerfile 中如果存在多个 ENTRYPOINT 指令，仅最后一个生效。



[Docker常用配置](https://zahui.fan/posts/4bc23141/)

-------



### mysql



##### 集群

- [在线重建MySQL主从同步](https://www.iots.vip/post/rebuild-mysql-master-slave-replication.html)



##### 主从原理

- [MySQL 主从模式采用 GTID 的实践](https://www.51cto.com/article/744435.html)



### redis

- [3主3从Redis集群搭建与扩缩容](https://www.peterjxl.com/Docker/redis-cluster/#%E6%90%AD%E5%BB%BA%E9%9B%86%E7%BE%A4)
- [Redis 高性能之 IO 多路复用](https://xie.infoq.cn/article/b3816e9fe3ac77684b4f29348)



### gitlab

- [GitLab跨版本升级并迁移到Docker环境](https://www.iots.vip/post/gitlab-update-to-docker.html)



### nginx

- [Nginx中间件安全基线配置与操作指南](https://i4t.com/19257.html)
- [[Nginx] – 性能优化 – 配置文件优化 [一]](https://i4t.com/570.html)

- [[Nginx] – 性能优化 – 配置文件优化 [二]](https://i4t.com/586.html)

- [Nginx - 知识体系](https://notes.youngkbt.cn/nginx/)





### k8s

[helm3使用记录](https://mutoulazy.github.io/2020/11/03/kubernetes/helm3-record/)



### java

[java生产环境内存调优](https://github.com/vipcolud/monitor)

