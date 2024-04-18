#### 拉取旧仓库代码
```
git clone http://gitlab.tyltxt.com/thylin/landing_page.git
```



#### 添加新的远程仓库
```
git remote add new-origin git@gitlab.jishuin.top:live1/barder-ChatTogetherNew.git
```



#### 查看所有的分支
```
git ls-remote . | grep 'refs/remotes/origin/' | grep -v 'HEAD' | awk -F 'origin/' '{print $2}' 
```



#### 查看所有的分支并全部上传到远程仓库

```
git ls-remote . | grep 'refs/remotes/origin/' | grep -v 'HEAD' | awk -F 'origin/' '{print $2}' | xargs -I {} git push -f new-origin  --tags refs/remotes/origin/{}:refs/heads/{}
```



#### 拉取指定分支

```
git clone --branch master https://github.com/xuxueli/xxl-job.git
git clone --branch master --single-branch https://github.com/xuxueli/xxl-job.git
```

1. git clone git_仓库_url 获取全部branch内容，整体下载时间较长 & 所占磁盘空间较大
2. git clone -b git_分支名称 git_仓库_url 根上述 1. 结果一致
3. git clone -b git_分支名称 --single--branch git_仓库_url 获取指定分支的代码



#### 查看分支

```
#查看当前所在分支
git branch -l or git branch
```

