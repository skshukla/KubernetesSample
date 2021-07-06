#!/usr/bin/env bash

# --------------------------------------------
export POSTGRES_NODEPORT="${POSTGRES_NODEPORT:-30000}"
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
    echo 'Use [-h] option to see the usage'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}

function delete() {
    eval $(minikube docker-env)

    kubectl delete service postgres-service || true;
    kubectl delete deployment postgres-deployment || true;
    kubectl delete configmap postgres-config || true;
    kubectl patch pvc postgres-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl delete pvc postgres-pvc || true;
    kubectl delete pv postgres-pv || true;
}

function runPostgres() {
    eval $(minikube docker-env)

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/pg.yaml

}


while getopts "cdfhw" opt
do
   case "$opt" in
      a ) COMMAND_IS_APPLY="true" ;;
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
    runPostgres
else
    runPostgres
fi


if [[ "$START_WATCH" == "true" ]]; then
    $PROJ_DIR/scripts/watch_app postgres
fi
