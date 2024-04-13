docker run -d -u root -p 4545:8080 -p 50001:50000 --restart=always -v /opt/jenkens1:/var/jenkins_home -v /etc/localtime:/etc/localtime -v /opt/maven:/usr/local/maven -e JAVA_OPTS=-Duser.timezone=Asia/Shanghai --name jenkins1 jenkins/jenkins:lts-jdk8-business-node



Jenkins  50000:50000 8084:8080 3GB

        "HostConfig": {
            "Binds": [
                "/data/maven-repo:/opt/maven-repo",
                "/data/.ssh:/root/.ssh",
                "/data/jenkins_home:/var/jenkins_home",
                "/etc/localtime:/etc/localtime",
                "/data/apache-maven-3.8.6:/usr/local/maven"
            ],





Gitlab 5GB

 docker run -d -p 8443:443 -p 8080:80 -p 8022:22 --name gitlab --restart always -v /mnt/gitlab/etc:/etc/gitlab -v /mnt/gitlab/logs:/var/log/gitlab -v /mnt/gitlab/data:/var/opt/gitlab gitlab/gitlab-ce

        "HostConfig": {
            "Binds": [
                "/mnt/gitlab/etc:/etc/gitlab",
                "/mnt/gitlab/logs:/var/log/gitlab",
                "/mnt/gitlab/data:/var/opt/gitlab"
            ],



nexus 8081:8081 3GB

        "HostConfig": {
            "Binds": [
                "/mnt/nexus/data:/var/nexus-data"
            ],



jenkins-flutter 8048:8081 50001:50000。3GB

        "HostConfig": {
            "Binds": [
                "/mnt/data/jenkins-flutter/.ssh:/root/.ssh",
                "/mnt/data/jenkins-flutter/jenkins_home:/var/jenkins_home",
                "/mnt/data/jenkins-flutter/flutter:/usr/local/flutter",
                "/mnt/data/jenkins-flutter/androidSdk:/usr/local/androidSdk",
                "/etc/localtime:/etc/localtime"
            ],