### maven

#### maven命令详解

#### 完整命令详解

```
mvn archetype:create 创建Maven项目
mvn compile 编译源代码
mvn test-compile 编译测试代码
mvn test 运行测试
mvn site 生成项目相关信息的网站
mvn clean 清除项目的生成结果
mvn package 打包项目生成jar/war文件
mvn install 安装jar至本地库
mvn deploy 上传至私服
mvn eclipse:eclipse 生成Eclipse项目文件
mvn ieda:ieda 生成IDEA项目文件
mvn archetype:generate 反向生成maven项目的骨架
mvn -Dtest package 只打包不测试
mvn jar:jar 只打jar包
mvn test -skipping compile -skipping test-compile 只测试不编译也不编译测试
mvn eclipse:clean 清除eclipse的一些系统设置
mvn dependency:list 查看当前项目已被解析的依赖
mvn clean install -U 强制检查更新
mvn source:jar 打包源码
mvn jetty:run 运行项目于jetty上
mvn tomcat:run 运行项目于tomcat上
mvn -e 显示详细错误 信息:
mvn validate 验证工程是否正确，所有需要的资源是否可用
mvn integration-test 在集成测试可以运行的环境中处理和发布包
mvn verify 运行任何检查，验证包是否有效且达到质量标准
mvn generate-sources 产生应用需要的任何额外的源代码
mvn help:describe -Dplugin=help 输出Maven Help插件的信息
mvn help:describe -Dplugin=help -Dfull 输出完整的带有参数的目标列
mvn help:describe -Dplugin=compiler -Dmojo=compile -Dfull 获取单个目标的信息
mvn help:describe -Dplugin=exec -Dfull 列出所有Maven Exec插件可用的目标
mvn help:effective-pom 查看Maven的默认设置
mvn install -X 想要查看完整的依赖踪迹，打开 Maven 的调试标记运行
mvn install assembly:assembly 构建装配Maven Assembly
mvn dependency:resolve 打印已解决依赖的列表
mvn dependency:tree 打印整个依赖树
mvn dependency:sources 获取依赖源代码
-Dmaven.test.skip=true 跳过测试
-Dmaven.tomcat.port=9090 指定端口
-Dmaven.test.failure.ignore=true 忽略测试失败
```

#### 常用打包命令

```
mvn clean  install package -Dmaven.test.skip=true #清理之前项目生成结果并构建然后将依赖包安装到本地仓库跳过测试
mvn clean deploy package  -Dmaven.test.skip=true #构建并将依赖放入私有仓库
mvn --settings /data/settings.xml clean package -Dmaven.test.skip=true #指定maven配置文件构建
```



#### Maven指定jdk版本打包

[Maven指定jdk版本打包](https://srebro.cn/17/)

**环境：**

- centos7.9
- maven-3.6.3
- jdk8
- jdk11
- jenkins2.4

**背景：**

- A项目需要使用jdk8打包，运行在jdk8 环境上
- B项目需要使用jdk11打包，运行在jdk11 环境上
- jenkins 运行在jdk11环境上

**需求：**
需要在 jenkins 上 使用maven3.6.3 同时打包 A 和 B 项目

**解决方法：**

机器上部署jdk8，jdk11

```
[root@localhost ~]# cd /home/application/

[root@localhost application]# ls -l
total 2
drwxr-xr-x  8 root  root    96 May 10 14:53 jdk-11.0.2
drwxr-xr-x  7 10143 10143  245 Mar 12  2020 jdk1.8.0_251

```

机器上部署maven3.6.3-A，maven3.6.3-B

```
[root@localhost ~]# cd /home/application/
[root@localhost application]# ls -l
total 2
drwxr-xr-x  6 root  root    99 May 11 21:29 maven-3.6.3-A
drwxr-xr-x  6 root  root    99 May 11 21:29 maven-3.6.3-B
```

修改mvn 二进制可执行脚本，分别指定各自jdk版本的JAVA_HOME

```
#在mvn脚本的开头，加上一行指定JAVA_HOME路径

[root@localhost bin]# head -10 /home/application/maven-3.6.3-A/bin/mvn
export JAVA_HOME=/home/application/jdk1.8.0_251
#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at


#添加之后保存。在执行mvn -v 命令
[root@localhost bin]# /home/application/maven-3.6.3-A/bin/mvn -v
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /home/application/maven-3.6.3
Java version: 1.8.0_251, vendor: Oracle Corporation, runtime: /home/application/jdk1.8.0_251/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-1160.el7.x86_64", arch: "amd64", family: "unix"
```

```
#在mvn脚本的开头，加上一行指定JAVA_HOME路径

[root@localhost bin]# head -10 /home/application/maven-3.6.3-B/bin/mvn
export JAVA_HOME=/home/application/jdk-11.0.2
#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at


#添加之后保存。在执行mvn -v 命令
[root@localhost bin]# /home/application/maven-3.6.3-B/bin/mvn -v
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: /home/application/maven-3.6.3-B
Java version: 11.0.2, vendor: Oracle Corporation, runtime: /home/application/jdk-11.0.2
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-1160.el7.x86_64", arch: "amd64", family: "unix"
```

