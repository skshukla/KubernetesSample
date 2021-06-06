#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..


function runPostgres() {
    eval $(minikube docker-env)

    kubectl delete service postgres-service || true;
    kubectl delete deployment postgres-deployment || true;
    kubectl delete configmap postgres-config || true;
    kubectl patch pvc postgres-pv-claim -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete persistentvolumeclaims postgres-pv-claim || true;
    kubectl delete persistentvolumes postgres-pv-volume || true;

    kubectl apply -f $PROJ_DIR/k8scripts/database/01_config_map.yaml
    kubectl apply -f $PROJ_DIR/k8scripts/database/02_persistent_volume.yaml
    kubectl apply -f $PROJ_DIR/k8scripts/database/03_postgres.yaml

}

runPostgres