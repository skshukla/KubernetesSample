#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



function runPostgres() {
    eval $(minikube docker-env)

    kubectl delete service postgres-service || true;
    kubectl delete deployment postgres-deployment || true;
    kubectl delete configmap postgres-config || true;
    kubectl patch pvc postgres-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete persistentvolumeclaims postgres-pv-claim || true;
    kubectl delete persistentvolumes postgres-pv-volume || true;

    kubectl apply -f $SCRIPT_DIR/pg.yaml

}

runPostgres