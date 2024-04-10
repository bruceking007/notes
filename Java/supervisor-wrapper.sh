#!/bin/bash
#date 2022-03-06
#Source: http://serverfault.com/questions/425132/controlling-tomcat-with-supervisor
function shutdown()
{
    date
    echo "Shutting down Tomcat"
    unset CATALINA_PID # Necessary in some cases
    $CATALINA_HOME/bin/catalina.sh stop
}

# Kill all remaining processes
function killjava()
{
    pid=$(ps aux | grep $CATALINA_BASE | grep -v grep |grep jdk| awk '{print $2}')
    if [ ! $pid ];then
        echo "Tomcat Not Running"
    else
        kill -9 $pid
    fi
}


date
echo "Starting Tomcat"
export JAVA_HOME="/usr/java/jdk"
export CATALINA_HOME="/home/java/wm-1"
export CATALINA_BASE="/home/java/wm-1"
export CATALINA_PID=/tmp/$$

rm -f /tmp/[0-9]*
killjava && . $CATALINA_HOME/bin/catalina.sh start

# Allow any signal which would kill a process to stop Tomcat
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP

echo "Waiting for `cat $CATALINA_PID`"
wait `cat $CATALINA_PID`
