# shell脚本中自动获取 GitHub 最新版本号

# 获取Github最新版本

利用 `GitHub API` 获取最新 `Releases` 的版本号，以 `iina` 为例：

```
wget -qO- -t1 -T2 "https://api.github.com/repos/lhc70000/iina/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'
```

或者借助第三方工具 `jq` ：

```
wget -qO- -t1 -T2 "https://api.github.com/repos/lhc70000/iina/releases/latest" | jq -r '.tag_name'
```

## 代码解释

### 主字段

`https://api.github.com/repos/lhc70000/iina/releases/latest` 这里用的是 GitHub 的官方 API，格式为 `https://api.github.com/repos/{项目名}/releases/latest` 打开上述链接后，可见包含下述字段的内容：

```
"html_url": "https://github.com/lhc70000/iina/releases/tag/v0.0.15.1",
"id": 10774475,
"node_id": "MDc6UmVsZWFzZTEwNzc0NDc1",
"tag_name": "v0.0.15.1",
"target_commitish": "0.0.15.1",
"name": "v0.0.15.1",
```

那么这里的 `tag_name` 后面的值就是我们所需要的东西。

### wget 参数

```
wget -qO- -t1 -T2` ，在这里我们使用了 4 个参数，分别是 `q` , `O-` , `t1` , `T2
```

- `-q` : `q` 就是 `quiet` 的意思了，没有该参数将会显示从请求到输出全过程的所有内容，这肯定不是我们想要的。
- `-O-`: `-O` 是指把文档写入文件中，而 `-O-` 是将内容写入标准输出，而不保存为文件。（注：这里是大写英文字母 `O` (Out)，不是数字 `0` ）
- `-t1` : 设定最大尝试链接次数为 `1` 次，防止失败后反复获取，导致后续脚本无法执行。
- `-T2` : 设定响应超时的秒数为 `2` 秒，防止失败后反复获取，导致后续脚本无法执行。

### 筛选参数

- `jq -r '.tag_name'` ：该命令需要先安装 `jq` ，`.tag_name` 取得该键值，`-r` 参数删除键值中的 `"`
- `grep "tag_name"` : `grep` 是 Linux 一个强大的文本搜索工具，在本代码中输出 `tag_name` 所在行，即输出 `"tag_name": "v0.0.15.1",`
- `head -n 1` : `head -n` 用于显示输出的行数，考虑到某些项目可能存在多个不同版本的 `tag_name` ，这里我们只要第一个。
- `awk -F ":" '{print $2}'` : `awk` 主要用于文本分析，在这里指定 `:` 为分隔符，将该行切分成多列，并输出第二列。于是我们得到了 `(空格)"v0.0.15.1",`
- `sed 's/\"//g;s/,//g;s/ //g'` : 在这里 `sed` 用于数据查找替换，如 `sed 's/要被取代的字串/新的字串/g'` ，因此本段命令可分为 3 个，以 `;` 分隔。`s/\"//g` 即将 `"` 删除（反斜杠是为了防止引号被转义），以此类推，最终留下我们需要的内容：`v0.0.15.1` 。

# 应用

还是以上面那个项目为例，提取版本号自然是想下载，其应用下载路径为：

```
https://github.com/iina/iina/releases/download/v0.0.15.1/IINA.v0.0.15.1.dmg
```

对比发现，我们只需要将版本号换成对应的变量即可：

```
# 定义版本变量
tag=$(wget -qO- -t1 -T2 "https://api.github.com/repos/lhc70000/iina/releases/latest" | jq -r '.tag_name')
# 下载链接替换为变量
wget https://github.com/iina/iina/releases/download/${tag}/IINA.${tag}.dmg
```