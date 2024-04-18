#### zsh

```shell
yum install -y curl git zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="candy"/g' /root/.zshrc
#更改时间为24小时制
cd ~/.oh-my-zsh/themes &&  sed -i 's/%X/%T/g' candy.zsh-theme && source /root/.zshrc



------
sh -c "$(curl -fsSL https://raw.githubusercontent.com/mmeta007/shell/main/intZsh.sh)"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="candy"/g' /root/.zshrc
source /root/.zshrc

```

插件

```shell

#1 zsh-autosuggestions：历史补全
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions

#2 Incremental completion on zsh:实时补全
##创建文件夹
mkdir $ZSH_CUSTOM/plugins/incr
##下载
curl -fsSL https://mimosa-pudica.net/src/incr-0.2.zsh -o $ZSH_CUSTOM/plugins/incr/incr.zsh
##配置
echo 'source $ZSH_CUSTOM/plugins/incr/incr.zsh' >> ~/.zshrc
##激活
source ~/.zshrc

#3 zsh-syntax-highlighting：语法高亮
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#4 aliases
#5 extract
#6 z
```

```shell
#保证插件顺序,zsh-syntax-highlighting 必须在最后一个
sed -i 's/^plugins.*/plugins=(git aliases extract z zsh-autosuggestions zsh-syntax-highlighting)/g' /root/.zshrc
source ~/.zshrc
```



#### PS1

```
PS1='[\[\e[1;35m\]\u\[\e[1;33m\]@\[\e[1;32m\]\h \[\e[1;0m\]\e[4m`pwd`\e[m\e[1;37m \[\e[1;0m\]\[\e[1;34m\]\t\[\e[1;0m\]]\n\[\e[1;31m\]\$\[\e[0m\] '
```



#### jdk 11

https://www.azul.com/downloads/?version=java-8-lts&os=centos&architecture=x86-64-bit&package=jdk

```
wget https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_x64.tar.gz

/etc/profile
export JAVA_HOME=/usr/java/jdk
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```



#### vim

```
set nocompatible                 "去掉有关vi一致性模式，避免以前版本的bug和局限    
set nu!                                    "显示行号
set guifont=Luxi/ Mono/ 9   " 设置字体，字体名称和字号
filetype on                              "检测文件的类型     
set history=1000                  "记录历史的行数
set background=dark          "背景使用黑色
syntax on                                "语法高亮度显示
set autoindent                       "vim使用自动对齐，也就是把当前行的对齐格式应用到下一行(自动缩进）
set cindent                             "（cindent是特别针对 C语言语法自动缩进）
set smartindent                    "依据上面的对齐格式，智能的选择对齐方式，对于类似C语言编写上有用   
set tabstop=4                        "设置tab键为4个空格，
set shiftwidth =4                   "设置当行之间交错时使用4个空格     
set ai!                                      " 设置自动缩进 
set showmatch                     "设置匹配模式，类似当输入一个左括号时会匹配相应的右括号      
set guioptions-=T                 "去除vim的GUI版本中得toolbar   
set vb t_vb=                            "当vim进行编辑时，如果命令错误，会发出警报，该设置去掉警报       
set ruler                                  "在编辑过程中，在右下角显示光标位置的状态行     
set nohls                                "默认情况下，寻找匹配是高亮度显示，该设置关闭高亮显示     
set incsearch                     "在程序中查询一单词，自动匹配单词的位置；如查询desk单词，当输到/d时，会自动找到第一个d开头的单词，当输入到/de时，会自动找到第一个以ds开头的单词，以此类推，进行查找；当找到要匹配的单词时，别忘记回车 
set backspace=2           " 设置退格键可用
修改一个文件后，自动进行备份，备份的文件名为原文件名加“~”后缀
if has("vms")
      set nobackup
      else
      set backup
      endif
```

