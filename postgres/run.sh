#!/usr/bin/env bash

# --------------------------------------------
export POSTGRES_NODEPORT="${POSTGRES_NODEPORT:-30000}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh

function runPostgres() {
    eval $(minikube docker-env)

    kubectl delete service postgres-service || true;
    kubectl delete deployment postgres-deployment || true;
    kubectl delete configmap postgres-config || true;
    kubectl patch pvc postgres-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete pvc postgres-pvc || true;
    kubectl delete pv postgres-pv || true;

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/pg.yaml

}


runPostgres