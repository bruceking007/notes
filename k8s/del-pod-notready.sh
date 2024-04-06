#!/bin/bash
# https://www.cnblogs.com/wukc/p/14614291.html
kubectl get pods --all-namespaces|egrep -v 'Running|Completed'|awk '{print $1,$2}'|while read -r line
do
    namespaces=`echo $line|awk '{print $1}'`
    podname=`echo $line|awk '{print $2}'`
    echo $namespaces--$podname
    kubectl delete pod $podname -n $namespaces
done
