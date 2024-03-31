#!/bin/bash
blue() {
    echo -e "\033[34m $1  \033[0m" && sleep 1
}

red() {
    echo -e "\033[31m $1  \033[0m" && sleep 1
}

if test -d /usr/local/include/jemalloc;then
    blue "jemalloc已部署"
    red "设置jemalloc软链接"
    ln -sfv /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
fi


blue "安装 autogen autoconf"
yum -y install autogen autoconf

install () {
    tar -xf jemalloc-5.2.1.tar.bz2 && cd jemalloc-5.2.1
    ./autogen.sh
    make -j4
    make install
    ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
}

blue "下载and解压and部署"
if test -f jemalloc-5.2.1.tar.bz2;then 
    install 
else 
    while true; do
        #wget --no-check-certificate https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
        wget https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
        if [ "$?" != 0 ];then 
            red "未下载成功，将继续尝试下载，请耐心等待！" 
        else 
            blue "下载成功,开始部署！"
            install
            break
        fi
    done
fi

