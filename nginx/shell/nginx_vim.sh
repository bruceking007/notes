#!/bin/bash
#desc nginx语法高亮
mkdir -p ~/.vim/syntax && cd ~/.vim/syntax
wget --no-check-certificate http://www.vim.org/scripts/download_script.php?src_id=14376 -O nginx.vim >/dev/null
echo "au BufRead,BufNewFile /usr/local/nginx/conf/* set ft=nginx" > ~/.vim/filetype.vim
#其中路径/usr/local/nginx/conf/*为你的nginx.conf文件路径
