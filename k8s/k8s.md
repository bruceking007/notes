### 教程

#### Kubernetes 中文指南/云原生应用架构实战手册

https://jimmysong.io/kubernetes-handbook/



#### 和我一步步部署 kubernetes 集群

https://github.com/opsnull/follow-me-install-kubernetes-cluster



#### 《从Docker到Kubernetes进阶课程》在线文档

https://github.com/cnych/kubernetes-learning



#### Kubernetes教程  

值得一看

https://kuboard.cn/learning/



#### kuboard

- https://github.com/eip-work/kuboard-press
- https://kuboard.cn/install/v3/install.html



### 在线实验环境

- [Killercoda](https://killercoda.com/playgrounds/scenario/kubernetes)
- [玩转 Kubernetes](https://labs.play-with-k8s.com/)

https://labs.play-with-k8s.com 

```
ctrl+inert #复制
shift+insert #黏贴
```

```shell
 You can bootstrap a cluster as follows:

 1. Initializes cluster master node:

 kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16

-----------------------------
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.8:6443 --token 0zpd0t.r983ei59iqyjpy29 \
        --discovery-token-ca-cert-hash sha256:986df2ff08c7e0faca3e617cd976e8ee61920c2783c1851c5eb7ed5ace6e04e1 
Waiting for api server to startup
Warning: resource daemonsets/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
daemonset.apps/kube-proxy configured


Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.8:6443 --token 0zpd0t.r983ei59iqyjpy29 \
        --discovery-token-ca-cert-hash sha256:986df2ff08c7e0faca3e617cd976e8ee61920c2783c1851c5eb7ed5ace6e04e1 
Waiting for api server to startup
---------------------------------------------------------------

 2. Initialize cluster networking:

 kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
 
  3. (Optional) Create an nginx deployment:

 kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
```

```
#其他节点加入集群
kubeadm join 192.168.0.8:6443 --token 0zpd0t.r983ei59iqyjpy29 \
        --discovery-token-ca-cert-hash sha256:986df2ff08c7e0faca3e617cd976e8ee61920c2783c1851c5eb7ed5ace6e04e1 
```



### 其他

[Kubernetes中强制删除Terminating状态资源](https://www.coolops.cn/archives/kubernetes-zhong-qiang-zhi-shan-chu-terminating-zhuang-tai-zi-yuan)
