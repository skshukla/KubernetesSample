#!/usr/bin/env bash

# --------------------------------------------
export APICURIO_REGISTRY_PORT="${APICURIO_REGISTRY_PORT:-30109}"
# --------------------------------------------

export NS=apicurio

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

START_WATCH="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"



function helpFunction() {
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}

function delete() {
    eval $(minikube docker-env)
    kubectl delete ns $NS
}


function runApicurioRegistry() {
    eval $(minikube docker-env)
    kubectl create ns $NS

    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
            echo 'Cluster mode is not supported!!!!'
            exit 1;
        else
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/apicurio-registry.yaml
    fi
}


while getopts "dfhw" opt
do
   case "$opt" in
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      h ) helpFunction && exit 0;;
      w ) START_WATCH="true" ;;
      ? ) helpFunction ;;
   esac
done

# ------------------------------------------------------------

echo 'START_WATCH: {'$START_WATCH'}'
echo 'FORCE_CLEAN: {'$FORCE_CLEAN'}'
echo 'RUN_AS_CLUSTER: {'$RUN_AS_CLUSTER'}'



if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runApicurioRegistry
else
    runApicurioRegistry
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n $NS get svc,deployments,pods -o wide --show-labels"
fi

