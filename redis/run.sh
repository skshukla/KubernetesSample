#!/usr/bin/env bash

# --------------------------------------------
export REDIS_PRIMARY_NODEPORT="${REDIS_PRIMARY_NODEPORT:-30010}"
export REDIS_REPLICA_NODEPORT="${REDIS_REPLICA_NODEPORT:-30011}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh

function runPostgres() {
    eval $(minikube docker-env)


    kubectl delete deployment redis-primary-deployment redis-replica-deployment || true;
    kubectl delete svc redis-primary-svc redis-replica-svc || true;

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/redis.yaml

    echo "Some useful commands: =>"
    echo '-------------------'
    echo "redis-cli -h vm-minikube -p ${REDIS_PRIMARY_NODEPORT}"
    echo "redis-cli -h vm-minikube -p ${REDIS_REPLICA_NODEPORT}"
    echo "keys *"
    echo "set k1 v1"
    echo "get k1"

}


runPostgres