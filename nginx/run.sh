#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function runNginx() {
    eval $(minikube docker-env)
    rm -rf $SCRIPT_DIR/contents-runtime
    mkdir -p $SCRIPT_DIR/contents-runtime

    kubectl delete configmap nginx-conf || true;
    kubectl delete deployment nginx-deployment || true;
    kubectl delete service nginx-service || true;

    kubectl patch pvc nginx-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete persistentvolumeclaims nginx-pvc || true;
    kubectl delete persistentvolumes nginx-pv || true;


    kubectl create cm nginx-conf --from-file=$SCRIPT_DIR/config/nginx.conf
    kubectl apply -f $SCRIPT_DIR/nginx.yaml


    sleep 2
    cp -v -rf $SCRIPT_DIR/contents-src/* $SCRIPT_DIR/contents-runtime

}

runNginx