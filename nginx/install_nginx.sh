#!/bin/bash
#date:2021-12-20
#des:install tengine2.3.3
#auth:wm

#注释函数
notes() {
    echo -e "\033[34m $1  \033[0m" && sleep 2
}

notes \#是否root用户
if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    exit 1
fi

DownDir=/usr/local/src/tengine
PWD=`pwd`

notes \#判断是否在src目录
if [ $PWD != '/usr/local/src/tengine' ]; then
    echo "please move file to /usr/local/src/tengine"
    exit 1
fi

#安装依赖
notes \#安装依赖
yum install -y libxml2 libxml2-dev libxslt-devel gd gd-devel yajl yajl-devel

function check_ok(){    ##Check it Fail or Success 自检函数
    [ $? -ne 0 ] && exit 1 && echo "$1 is Fail!" || echo "$1 is Success!"
}

#Check User 确认用户存在函数
notes \#CheckUser确认用户存在函数
function check_user(){
    grep "$1" /etc/group
    [ $? != 0 ] && groupadd $1
    grep "$1" /etc/passwd
    [ $? != 0 ] && useradd -s /sbin/nologin -g $1 $1
}

function UnZip(){   ##解压函数
    TarName=$1
    TarType=${TarName##*.}
    #if [ ! -f $DownDir/$TarName ] ;then
        #wget -P $DownDir $Url/$TarName
    #fi
    if [ "$TarType" == "zip" ] ;then
        cd $DownDir && unzip -o $TarName
        check_ok
    else
        tar xf $DownDir/$TarName -C $DownDir/
        check_ok
    fi
    ser=`echo $TarName | sed -e 's#^\(.*\)-[0-9]*.*#\1#g'`       #service name
    dir=`ls $DownDir | grep $ser |grep -v tar.gz`   #unzip dir
    if [ -z $dir ] ;then
        ser=`echo $TarName | awk -F "[._-]" '{print $1}'`
        dir=`ls $DownDir | grep $ser | grep -v tar.gz`
    fi
    echo -e "\033[34m -----------\n TarName=$TarName |ServiceName=$ser |UnzipDir=$dir \n-----------  \033[0m"
}

function Install(){ ##安装函数,依赖解压函数
    cd $DownDir/$dir
    ./configure $1
    check_ok $ser
    make && make install
    check_ok $ser
    cd $DownDir
    rm -rf $dir
    }

#解压soft
array=(zlib-1.2.11.tar.gz pcre-8.45.tar.gz openssl-1.1.1m.tar.gz ngx_cache_purge-2.3.tar.gz ngx_http_geoip2_module-3.3.tar.gz nginx_tcp_proxy_module.tar.gz)
for i in ${array[@]};do UnZip $i ;done

#部署jemalloc
notes \#部署jemalloc
if [ -d /usr/local/include/jemalloc ];then
    echo "jemalloc already installed"
else
    UnZip "jemalloc-5.2.1.tar.bz2"
    cd $DownDir/$dir
    ./autogen.sh
    make && make install
    check_ok
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    check_ok
fi

#install LuaJIT
notes \#install_LuaJIT
#cd $DownDir && tar xf luajit2-2.1-20211210.tar.gz && cd luajit2-2.1-20211210 && make && make install
UnZip "luajit2-2.1-20211210.tar.gz"
cd $DownDir/$dir
make
check_ok $ser
make install
check_ok $ser

#install libmaxminddb
notes \#install_libmaxminddb
#cd $DownDir && tar xf tar xf libmaxminddb-1.6.0.tar.gz && cd libmaxminddb-1.6.0 && ./configure && make && make install
UnZip "libmaxminddb-1.6.0.tar.gz" && Install
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

#install GeoIP.tar.gz
notes \#install_GeoIP.tar.gz
#cd $DownDir && tar xf GeoIP.tar.gz && cd GeoIP-1.4.8 && ./configure && make && make install
UnZip "GeoIP.tar.gz" && Install

#install tengine
notes \#"install tengine"
UnZip "tengine-2.3.3.tar.gz"
cd $DownDir/$dir
./configure \
--pid-path=/var/run/nginx.pid \
--error-log-path=/data/nginx/logs/main/error.log \
--http-log-path=/data/nginx/logs/main/access.log \
--http-client-body-temp-path=/data/nginx/tmps/nginx_client \
--http-proxy-temp-path=/data/nginx/tmps/nginx_proxy \
--http-fastcgi-temp-path=/data/nginx/tmps/nginx_fastcgi \
--with-jemalloc \
--with-pcre=$DownDir/pcre-8.45 \
--with-openssl=$DownDir/openssl-1.1.1m \
--with-zlib=$DownDir/zlib-1.2.11 \
--with-openssl-opt=-fPIC \
--with-http_lua_module \
--with-luajit-inc=/usr/local/include/luajit-2.1 \
--with-luajit-lib=/usr/local/lib \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_realip_module \
--with-http_ssl_module \
--with-http_sub_module \
--with-http_xslt_module \
--with-http_image_filter_module=dynamic \
--with-http_geoip_module=dynamic \
--with-stream_geoip_module=dynamic \
--without-http_uwsgi_module \
--without-http_scgi_module \
--without-select_module \
--without-poll_module \
--add-module=$DownDir/ngx_cache_purge-2.3 \
--add-module=$DownDir/ngx_http_geoip2_module-3.3 \
--add-module=$DownDir/nginx_tcp_proxy_module \
--add-module=./modules/ngx_http_concat_module \
--add-module=./modules/ngx_http_sysguard_module \
--add-module=./modules/ngx_http_footer_filter_module \
--add-module=./modules/ngx_http_upstream_session_sticky_module \
--add-module=./modules/ngx_http_user_agent_module \
--add-module=./modules/ngx_http_upstream_check_module \
--add-module=./modules/ngx_http_trim_filter_module \
--add-module=./modules/ngx_http_upstream_consistent_hash_module \
--add-module=./modules/ngx_http_upstream_dynamic_module \
--add-module=./modules/ngx_http_upstream_vnswrr_module \
--add-module=./modules/ngx_multi_upstream_module \
--add-module=./modules/ngx_slab_stat \
--add-module=./modules/ngx_http_slice_module \
--add-module=./modules/ngx_http_reqstat_module \
--add-module=./modules/ngx_http_proxy_connect_module \
--add-module=./modules/ngx_debug_timer \
--add-module=./modules/ngx_debug_pool \
--add-module=./modules/ngx_backtrace_module

check_ok $ser
#install patch
notes \#"install patch"
patch -p1 < $DownDir/nginx_tcp_proxy_module/tcp.patch
check_ok $ser
make && make install
check_ok $ser

#check nginx
notes \#"check nginx"
check_user nginx

#日志目录
notes \#日志目录
mkdir -pv /data/nginx/tmps/nginx_client
mkdir -pv /data/nginx/logs/{main,hack,proxy}
chown -R nginx /data/nginx

#解压conf配置模板
notes \#解压conf配置模板
cd $DownDir && rm -rf /usr/local/nginx/conf && tar xf conf.tar.gz -C /usr/local/nginx/

#测试配置是否问题
notes \#测试配置是否问题
/usr/local/nginx/sbin/nginx -t

#robots
notes \#"add robots"
cat > /usr/local/nginx/html/robots.txt <<EOF
User-agent: Baiduspider
Disallow: /agent*

User-agent: Googlebot
Disallow: /agent*

User-agent: *
Disallow: /
EOF

#创建启动脚本并注册服务
notes \#创建启动脚本并注册服务
cat <<EOF > /etc/init.d/nginx
#!/bin/bash
# chkconfig: - 30 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx Settings

NGINX_SBIN="/usr/local/nginx/sbin/nginx"
NGINX_CONF="/usr/local/nginx/conf/nginx.conf"
NGINX_PID="/var/run/nginx.pid"
RETVAL=0
prog="Nginx"

start() {
        echo -n \$"Starting \$prog: "
        mkdir -p /dev/shm/nginx_temp
        daemon \$NGINX_SBIN -c \$NGINX_CONF
        RETVAL=\$?
        echo
        return \$RETVAL
}

stop() {
        echo -n \$"Stopping \$prog: "
        killproc -p \$NGINX_PID \$NGINX_SBIN -TERM
        rm -rf /dev/shm/nginx_temp
        RETVAL=\$?
        echo
        return \$RETVAL
}

reload(){
        echo -n \$"Reloading \$prog: "
        killproc -p \$NGINX_PID \$NGINX_SBIN -HUP
        RETVAL=\$?
        echo
        return \$RETVAL
}

restart(){
        stop
        start
}

configtest(){
    \$NGINX_SBIN -c \$NGINX_CONF -t
    return 0
}

case "\$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: \$0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac

exit \$RETVAL
EOF

chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
service nginx start
i=`ps -C nginx --no-heading |wc -l`
if [ "$i" == "0" ];then
    echo "Nginx start faild" && service nginx restart
fi

#软链接
notes \#添加软链接
ln -sfv /usr/local/nginx/sbin/nginx /usr/bin/nginx

#NGINX语法高亮
notes \#NGINX语法高亮
mkdir -p ~/.vim/syntax && cd ~/.vim/syntax
wget --no-check-certificate http://www.vim.org/scripts/download_script.php?src_id=14376 -O nginx.vim >/dev/null
echo "au BufRead,BufNewFile /usr/local/nginx/conf/* set ft=nginx" > ~/.vim/filetype.vim

#开启防火墙的80端口
#notes \#开启防火墙的80端口
#iptables -I INPUT -p tcp --dport 80 -j ACCEPT && service iptables save

#按天切割nginx 日志
notes \#按天切割nginx日志
mkdir -p /opt/scripts
cd $DownDir && chmod +x nginxLog_cut.sh &&  cp -a ./nginxLog_cut.sh /opt/scripts/

#建立计划任务，每天0点0分执行nginx 日志切割
notes \#"建立计划任务，每天0点0分执行nginx 日志切割"
echo "0 0 * * * root /bin/bash /opt/scripts/nginxLog_cut.sh" >> /etc/crontab

#验证
notes \#验证nginx
ps -ef|grep nginx

notes \#验证jemalloc
lsof -n|grep jemalloc
