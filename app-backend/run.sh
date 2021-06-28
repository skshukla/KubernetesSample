#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..



function getPortForService() {

  http://vm-minikube:30003
}


function runApp() {

    eval $(minikube docker-env)

    $PROJ_DIR/BackendAppOne/scripts/run-docker.sh

    docker images

    kubectl apply -f $SCRIPT_DIR/app-backend.yaml

    /bin/sh -c "curl -w '\n' http://vm-minikube:30003/ip"

}

#getPortForService nginx-service
#getPortForService backendone-service
#getPortForService postgres-service


runApp