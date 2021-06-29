#!/usr/bin/env bash


# --------------------------------------------
export API_SERVICE_NODEPORT="${API_SERVICE_NODEPORT:-30002}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

#source $PROJ_DIR/scripts/util.sh


function runApp() {
    eval $(minikube docker-env)

    kubectl delete svc backendone-service || true;
    kubectl delete deployment backend-app-one-deployment || true;


    $PROJ_DIR/BackendAppOne/scripts/run-docker.sh

    docker images

    $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/app-backend.yaml

    echo "curl -w '\n' http://vm-minikube:${API_SERVICE_NODEPORT}/ip"

}

runApp