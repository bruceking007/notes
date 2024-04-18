### [tomcat配置多域名站点启动时项目重复加载多次](https://www.xiongge.club/biancheng/java/1042.html)

在配置[tomcat](https://www.xiongge.club/tag/tomcat)多站点的时候遇到一个问题，目前有两个java web项目，要求放在一个tomcat下并通过二级域名问。所以我就在server.xml增加了多个host的配置。但是配置成功后，启动tomcat发现，项目居然被重复加载了3次。感觉很莫名，然后就google了一下，发现原来解决办法也很简单。所以记录一下。

博主服务器是ubuntu 14.04，tomcat用的是apache-tomcat-7.0.63，默认server.xml如下图

![tomcat配置多域名站点启动时项目重复加载多次](https://www.xiongge.club/wp-content/uploads/2017/03/447c07553b311171239267d79872328b.png)

关键位置是host节点的配置，默认情况host节点下是没有Context节点的，如果需要多站点，就必须添加context指定web应用的文件路径

[appBase](https://www.xiongge.club/tag/appbase)是指定虚拟主机的目录,可以指定绝对目录,也可以指定相对于的相对目录.如果没有此项,默认为/webapps。
docBase是指定Web应用的文件路径.可以给定绝对路径,也可以给定相对于Host的appBase属性的相对路径. 如果Web应用采用开放目录结构,那就指定Web应用的根目录;如果Web应用是个WAR文件,那就指定WAR文件的路径。

出现上述问题的原因是tomcat加载玩appBase=”webapps”之后又去加载docBase，因此造成加载两次项目的问题

**我的解决办法是去掉appBase属性 并将项目放在webapps目录以外，用docBase指定需要加载的项目绝对路径**

![tomcat配置多域名站点启动时项目重复加载多次](https://www.xiongge.club/wp-content/uploads/2017/03/4484e4590539b36a0e95359ece07c39c.png)