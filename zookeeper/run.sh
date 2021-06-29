#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



function runZK() {
    eval $(minikube docker-env)
    kubectl apply -f $SCRIPT_DIR/zk.yaml

}

runZK