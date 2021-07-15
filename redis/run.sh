#!/usr/bin/env bash

# --------------------------------------------
export REDIS_PRIMARY_NODEPORT="${REDIS_PRIMARY_NODEPORT:-30010}"
export REDIS_REPLICA_NODEPORT="${REDIS_REPLICA_NODEPORT:-30011}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh

START_WATCH="false"
DELETE_RESOURCES_ONLY="false"
FORCE_CLEAN="false"


function helpFunction() {
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}


function delete() {
    eval $(minikube docker-env)
    kubectl delete ns redis
}


function runRedis() {

    eval $(minikube docker-env)

    kubectl create ns redis

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/redis.yaml

    echo "Some useful commands: =>"
    echo '-------------------'
    echo "redis-cli -h vm-minikube -p ${REDIS_PRIMARY_NODEPORT}"
    echo "redis-cli -h vm-minikube -p ${REDIS_REPLICA_NODEPORT}"
    echo "keys *"
    echo "set k1 v1"
    echo "get k1"

}



while getopts "dfhw" opt
do
   case "$opt" in
      d ) DELETE_RESOURCES_ONLY="true" ;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      h ) helpFunction ;; # Usage
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


# ------------------------------------------------------------

echo 'START_WATCH: {'$START_WATCH'}'
echo 'DELETE_RESOURCES_ONLY: {'$DELETE_RESOURCES_ONLY'}'
echo 'FORCE_CLEAN: {'$FORCE_CLEAN'}'

if [[ "$DELETE_RESOURCES_ONLY" == "true" ]]; then
    echo 'Going to delete the resources'
    delete
    exit 0; # In case of delete only, exit after deleting. to run the app with delete and run, us -f option to force clean.
fi

if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    sleep 8
    runRedis
else
    runRedis
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n redis get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi
