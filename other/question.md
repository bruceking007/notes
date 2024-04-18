oom-kill

https://www.cnblogs.com/MrLiuZF/p/15229868.html

https://jimmysong.io/docker-handbook/docs/memory_resource_limit.html



egrep -i -r 'killed process' /var/log

egrep -i -r 'oom-killer' /var/log

### 2.4 `--oom-kill-disable`

```bash
➜  ~ docker run -it --rm -m 100M --memory-swappiness=0 --oom-kill-disable ubuntu-stress:latest /bin/bash
root@f54f93440a04:/# stress --vm 1 --vm-bytes 200M  # 正常情况不添加 --oom-kill-disable 则会直接 OOM kill，加上之后则达到限制内存之后也不会被 kill
stress: info: [17] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
```

但是如果是以下的这种没有对容器作任何资源限制的情况，添加 `--oom-kill-disable` 选项就比较 **危险** 了：

```bash
$ docker run -it --oom-kill-disable ubuntu:14.04 /bin/bash
```

因为此时容器内存没有限制，并且不会被 oom kill，此时系统则会 kill 系统进程用于释放内存。