# 仅几 MB，0.0x 毫秒级查询！准确率 99.9% 的离线 IP 地址定位库



## 简介

Ip2region - 准确率99.9%的离线IP地址定位库，0.0x毫秒级查询，ip2region.db数据库只有数MB，提供了java,php,c,python,nodejs,golang,c#等查询绑定和Binary,B树,内存三种查询算法。

## 开源协议

使用 Apache-2.0 开源协议

## Ip2region特性

###### 99.9%准确率

- 数据聚合了一些知名ip到地名查询提供商的数据，这些是他们官方的的准确率，经测试着实比经典的纯真IP定位准确一些。
- ip2region的数据聚合自以下服务商的开放API或者数据(升级程序每秒请求次数2到4次):
- 01, >80%, 淘宝IP地址库（http://ip.taobao.com/）
- 02, ≈10%, GeoIP（https://geoip.com/）
- 03, ≈2%, 纯真IP库（http://www.cz88.net/）

备注：如果上述开放API或者数据都不给开放数据时ip2region将停止数据的更新服务。

###### 标准化的数据格式

每条ip数据段都固定了格式：

```
_城市Id|国家|区域|省份|城市|ISP_
```

只有中国的数据精确到了城市，其他国家有部分数据只能定位到国家，后前的选项全部是0，已经包含了全部你能查到的大大小小的国家（请忽略前面的城市Id，个人项目需求）。

###### 体积小

包含了全部的IP，生成的数据库文件 ip2region.db 只有几 MB，最小的版本只有1.5MB，随着数据的详细度增加数据库的大小也慢慢增大，目前还没超过8MB。

###### 查询速度快

全部的查询客户端单次查询都在0.x毫秒级别，内置了**三种查询算法**

- memory算法：整个数据库全部载入内存，单次查询都在0.1x毫秒内，C语言的客户端单次查询在0.00x毫秒级别。
- binary算法：基于二分查找，基于ip2region.db文件，不需要载入内存，单次查询在0.x毫秒级别。
- b-tree算法：基于btree算法，基于ip2region.db文件，不需要载入内存，单词查询在0.x毫秒级别，比binary算法更快。

任何客户端**b-tree都比binary算法快**，当然**memory算法固然是最快**的！

## 多查询客户端的支持

已经集成的客户端有：java、C#、php、c、python、nodejs、php扩展(php5和php7)、golang、rust、lua、lua_c, nginx。![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPqRoDt9TyzyYsic7yacyXLgauGFohNMJLuGuMnuFGz24avOYCG4qLnWq1Tn6TeOLDnicsLKKqqicJJcQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)![图片](https://mmbiz.qpic.cn/mmbiz_png/tuSaKc6SfPqRoDt9TyzyYsic7yacyXLgay60qDweldkKPqN56fpicKVicVJp3LDXhEE9rJPgaPP7yKN4uKZEhCA4A/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

## ip2region快速测试

请参考每个binding下的README说明去运行cli测试程序，例如C语言的demo运行如下：

```
cd binding/c/
gcc -g -O2 testSearcher.c ip2region.c
./a.out ../../data/ip2region.db
```

会看到如下cli界面：

```
initializing  B-tree ... 
+----------------------------------+
| ip2region test script            |
| Author: chenxin619315@gmail.com  |
| Type 'quit' to exit program      |
+----------------------------------+
p2region>> 101.105.35.57
2163|中国|华南|广东省|深圳市|鹏博士 in 0.02295 millseconds
```

输入IP地址开始测试，第一次会稍微有点慢，在运行命令后面接入binary,memory来尝试其他算法，建议使用b-tree算法，速度和并发需求的可以使用memory算法，具体集成请参考不同binding下的测试源码。

## ip2region安装

具体请参考每个binding下的README文档和测试demo，以下是一些可用的快捷安装方式：

maven仓库地址

```
<dependency>
    <groupId>org.lionsoul</groupId>
    <artifactId>ip2region</artifactId>
    <version>1.7.2</version>
</dependency>
```

nodejs

```
npm install node-ip2region --save
```

nuget安装

```
Install-Package IP2Region
```

php composer

```
# 插件来自：https://github.com/zoujingli/ip2region
composer require zoujingli/ip2region
```

## ip2region 并发使用

全部binding的各个search接口都不是线程安全的实现，不同线程可以通过创建不同的查询对象来使用，并发量很大的情况下，binary和b-tree算法可能会打开文件数过多的错误，请修改内核的最大允许打开文件数(fs.file-max=一个更高的值)，或者使用持久化的memory算法。

memorySearch接口，在发布对象前进行一次预查询(本质上是把ip2region.db文件加载到内存)，可以安全用于多线程环境。

## ip2region.db的生成

从1.8版本开始，ip2region开源了ip2region.db生成程序的java实现，提供了ant编译支持，编译后会得到以下提到的`dbMaker-{version}.jar`，对于需要研究生成程序的或者更改自定义生成配置的请参考${ip2region_root}/maker/java内的java源码。

从ip2region 1.2.2版本开始里面提交了一个dbMaker-{version}.jar的可以执行jar文件，用它来完成这个工作：

确保你安装好了java环境（不玩Java的童鞋就自己谷歌找找拉，临时用一用，几分钟的事情）cd到`${ip2region_root}/maker/java`，然后运行如下命令：

```
java -jar dbMaker-{version}.jar -src 文本数据文件 -region 地域csv文件 [-dst 生成的ip2region.db文件的目录]

# 文本数据文件：db文件的原始文本数据文件路径，自带的ip2region.db文件就是/data/ip.merge.txt生成而来的，你可以换成自己的或者更改/data/ip.merge.txt重新生成
# 地域csv文件：该文件目的是方便配置ip2region进行数据关系的存储，得到的数据包含一个city_id，这个直接使用/data/origin/global_region.csv文件即可
# ip2region.db文件的目录：是可选参数，没有指定的话会在当前目录生成一份./data/ip2region.db文件
```

获取生成的`ip2region.db`文件覆盖原来的`ip2region.db`文件即可

默认的`ip2region.db`文件生成命令:

```
cd ${ip2region_root}/java/
java -jar dbMaker-1.2.2.jar -src ./data/ip.merge.txt -region ./data/global_region.csv

# 会看到一大片的输出
```

## 源数据如何存储到ip2region.db

###### 源数据来源与结构

ip2region 的ip数据来自纯真和淘宝的ip数据库，每次抓取完成之后会生成 ip.merge.txt， 再通过程序根据这个源文件生成ip2region.db 文件。

ip.merge.txt 中每一行对应一条完整记录，每一条记录由ip段和数据组成，格式如下：

```
0.0.0.0|0.255.255.255|未分配或者内网IP|0|0|0|0
1.0.0.0|1.0.0.255|澳大利亚|0|0|0|0
1.0.1.0|1.0.3.255|中国|华东|福建省|福州市|电信
1.0.4.0|1.0.7.255|澳大利亚|0|0|0|0
1.0.8.0|1.0.15.255|中国|华南|广东省|广州市|电信
1.0.16.0|1.0.31.255|日本|0|0|0|0
1.0.32.0|1.0.63.255|中国|华南|广东省|广州市|电信
1.0.64.0|1.0.127.255|日本|0|0|0|0
1.0.128.0|1.0.255.255|泰国|0|0|0|0
1.1.0.0|1.1.0.255|中国|华东|福建省|福州市|电信
```

从左到右分别表示：起始ip,结束ip,国家，区域，省份，市，运营商。无数据区域默认为0。

最新的ip.merge.txt 有122474条记录，并且根据开始ip地址升序排列。

###### 如何生成ip2region.db

给定一个ip，如何快速从ip.merge.txt中找到该ip所属记录？最简单的办法就是顺序遍历，当该ip在某条记录起始和结束ip之间时，即命中。

这是低效的做法，如何提高查询性能？用过mysql和其他数据库的的都知道，使用索引。所以ip2region.db使用了内建索引，直接将性能提升到0.0x毫秒级别。

根据ip.merge.txt，为所有数据生成一份索引，并和数据地址组成一个索引项(index block), 然后按起始ip升序排列组成索引，并存储到数据文件的末尾，最终生成的ip2region.db文件大小只有3.5M。

此时的数据库文件中的每一条索引都指向一条对应的数据，也就是说如

```
|中国|华南|广东省|广州市|电信 
```

