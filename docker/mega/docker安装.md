### docker配置阿里云加速器

CentOS 7 (使用yum进行安装)

#### step 1: 安装必要的一些系统工具

```shell
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```



#### Step 2: 添加软件源信息

```shell
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
```



#### Step 3: 更新并安装 Docker-CE

```shell
sudo yum makecache fast
sudo yum -y install docker-ce
```



####  Step 4: 开启Docker服务

```shell
systemctl start docker 
systemctl enable docker
systemctl status docker 
```

[Docker安装](https://developer.aliyun.com/article/625258?spm=5176.21213303.J_6704733920.10.1c6c3edacyu9X1&scm=20140722.S_community@@文章@@625258._.ID_community@@文章@@625258-RL_docker安装-LOC_main-OR_ser-V_2-P0_1)

【加速器地址】

https://lb3cvacp.mirror.aliyuncs.com

#### Step 5: 生产环境配置参考

sudo 	
sudo tee /etc/docker/daemon.json <<-'EOF'
{
 "data-root":"/data/docker",
 "dns": ["223.5.5.5", "119.29.29.29"],
 "registry-mirrors": ["https://lb3cvacp.mirror.aliyuncs.com"],
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-level": "info",
 "log-opts": {
  "max-size": "100m",
  "max-file": "10"
 },
 "live-restore": true,
 "storage-driver": "overlay2",
 "storage-opts": [ "overlay2.override_kernel_check=true"],
 "bip": "10.10.0.1/24",
 "default-address-pools": [
   {"base": "10.10.0.0/16", "size": 24}
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

##### 以下是多个registry-mirrors

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
 "data-root":"/data/docker",
 "dns": ["223.5.5.5", "119.29.29.29"],
 "registry-mirrors": [
   "https://lb3cvacp.mirror.aliyuncs.com",
   "https://hub-mirror.c.163.com",
   "https://docker.mirrors.ustc.edu.cn",
   "https://registry.docker-cn.com"
],
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-level": "info",
 "log-opts": {
  "max-size": "100m",
  "max-file": "10"
 },
 "live-restore": true,
 "storage-driver": "overlay2",
 "storage-opts": [ "overlay2.override_kernel_check=true"],
 "bip": "10.10.0.1/24",
 "default-address-pools": [
   {"base": "10.10.0.0/16", "size": 24}
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker



**"iptables": false, 根据实际情况是否开启iptables**

data-root”:"/var/lib/docker", Docker运行时使用的根路径，默认/var/lib/docker。

dns: 设定容器DNS的地址，在容器的 /etc/resolv.conf文件中可查看。

registry-mirrors: 设置镜像加速。

log-level: 设置日志记录级别（“调试”,“信息”，“警告”，“错误”，“致命”）（默认为“信息”）。

max-size：单个日志文件最大尺寸，当日志文件超过此尺寸时会滚动，即不再往这个文件里写，而是写到一个新的文件里。默认值是-1，代表无限 

max-files：最多保留多少个日志文件。默认值是1 。

live-restore: true,在容器仍在运行时启用docker的实时还原。

storage-driver： Docker推荐使用[overlay2](https://docs.docker.com/storage/storagedriver/overlayfs-driver/#configure-docker-with-the-overlay-or-overlay2-storage-driver)作为Storage driver 。

bip为docker网桥默认网关

default-address-pools为docker默认地址池

在配置文件中添加以下内容，其中default-address-pools的base表示CIDR地址，size表示docker创建的网络的掩码长度，CIDR的掩码长度应该小于size，否则docker将会出现网络失败。这里使用10.10网段地址，其中CIDR为16为掩码，划分的网络子网掩码24位，理论可以划分出2(32-16)-(32-24)=28=256个子网。

踩坑：

· 较低版本的docker，不支持default-address-pools配置项，需要先升级Docker版本，具体方法参考[此文](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.cnblogs.com%2FPatrickLiu%2Fp%2F13901520.html)。

· 如果只添加bip配置，则只会对docker0网桥生效，并不会对docker-compose新创建的容器生效；

· https://www.jianshu.com/p/d87619a655b3