#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..


#eval $(minikube docker-env)
#MINIKUBE_IP=$(minikube ip)
#echo 'MINIKUBE_IP='$MINIKUBE_IP



source $SCRIPT_DIR/util.sh

function runProject() {

    PROJ_NAME=postgres
    $PROJ_DIR/$PROJ_NAME/run.sh

    PROJ_NAME=app-backend
    $PROJ_DIR/$PROJ_NAME/run.sh

    PROJ_NAME=nginx
    $PROJ_DIR/$PROJ_NAME/run.sh


    PROJ_NAME=zookeeper
    $PROJ_DIR/$PROJ_NAME/run.sh
}


runProject


