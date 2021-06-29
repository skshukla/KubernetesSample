#!/usr/bin/env bash

# --------------------------------------------
CONTAINER_RUNTIME_DIR_NAME=.contents-runtime
export NGINX_NODEPORT="${NGINX_NODEPORT:-30001}"
# --------------------------------------------
echo 'NGINX_NODEPORT='$NGINX_NODEPORT


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh

export RUNTIME_CONTENTS_DIR=$SCRIPT_DIR/$CONTAINER_RUNTIME_DIR_NAME

function runNginx() {
    eval $(minikube docker-env)
    rm -rf $RUNTIME_CONTENTS_DIR
    mkdir -p $RUNTIME_CONTENTS_DIR

    kubectl delete configmap nginx-conf || true;
    kubectl delete deployment nginx-deployment || true;
    kubectl delete service nginx-service || true;

    kubectl patch pvc nginx-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete persistentvolumeclaims nginx-pvc || true;
    kubectl delete persistentvolumes nginx-pv || true;


    kubectl create cm nginx-conf --from-file=$SCRIPT_DIR/config/nginx.conf


    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/nginx.yaml


    sleep 6
    cp -v -rf $SCRIPT_DIR/contents-src/* $RUNTIME_CONTENTS_DIR

    echo "curl -w '\n' http://vm-minikube:${NGINX_NODEPORT}"

}

runNginx