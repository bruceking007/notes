```yaml
version: '3'
services:
    centos7:
      container_name: centos7
      hostname: centos7
      image: centos:centos7-2009-v2
      restart: no
      volumes:
        - "./app:/app"
      #entrypoint: ["init"]
      entrypoint: ["bash","-c","/app/start_jupyter.sh"]
        #- "sh /app/start_jupyter.sh"
      ports:
        - "8888:8888"
```

```shell
cat app/start_jupyter.sh
#!/bin/bash
init
cd /app && nohup jupyter notebook --allow-root > jupyter.log 2>&1
```

