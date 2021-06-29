#!/usr/bin/env bash


# --------------------------------------------
export ZK_NODEPORT="${ZK_NODEPORT:-30003}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh

function runZK() {
    eval $(minikube docker-env)

    kubectl delete statefulset zookeeper
    kubectl delete svc zookeeper-headless zookeeper-service
    kubectl delete pvc datadir-zookeeper-0 datadir-zookeeper-1 datadir-zookeeper-2

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/zk.yaml

}

runZK