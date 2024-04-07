#!/bin/bash
blue() {
	echo -e "\033[34m $1  \033[0m" && sleep 1
}

red() {
	echo -e "\033[31m $1  \033[0m" && sleep 1
}

yum -y install perl-Digest-MD5
yum -y install perl-DBD-MySQL.x86_64

srcDir=/usr/local/src

cd $srcDir && wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/tarball/percona-xtrabackup-2.4.9-Linux-x86_64.tar.gz
tar xf percona-xtrabackup-2.4.9-Linux-x86_64.tar.gz
cp -a percona-xtrabackup-2.4.9-Linux-x86_64/bin/* /usr/bin/


cd $srcDir && wget http://ftp.de.debian.org/debian/pool/main/g/gcc-4.8/libstdc++6-4.8-dbg_4.8.4-1_amd64.deb
ar -x libstdc++6-4.8-dbg_4.8.4-1_amd64.deb
tar xvf data.tar.xz
cd ${srcDir}/usr/lib/x86_64-linux-gnu/debug && cp libstdc++.so.6.0.19 /usr/lib64/ 
cd /usr/lib64/ && rm -f libstdc++.so.6
ln -s libstdc++.so.6.0.19 libstdc++.so.6
strings /usr/lib64/libstdc++.so.6 | grep GLIBCXX




cd $srcDir && wget http://www.quicklz.com/qpress-11-linux-x64.tar
tar xvf qpress-11-linux-x64.tar
cp qpress /usr/bin


cd $srcDir && curl -O http://ftp.gnu.org/gnu/glibc/glibc-2.18.tar.gz
tar zxf glibc-2.18.tar.gz && cd glibc-2.18/
mkdir build && cd build/
../configure --prefix=/usr
make -j4
make install

xtrabackup -version