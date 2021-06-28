#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..


eval $(minikube docker-env)
MINIKUBE_IP=$(minikube ip)
echo 'MINIKUBE_IP='$MINIKUBE_IP

function updateHostFileForMiniKubeIP() {
    MINIKUBE_IP=$1
    sed -i '' '/vm-minikube/d' /private/etc/hosts
    echo "$MINIKUBE_IP    vm-minikube" >> /private/etc/hosts
    cat /private/etc/hosts
}



function runProject() {

    PROJ_NAME=postgres
    $PROJ_DIR/$PROJ_NAME/run.sh

    PROJ_NAME=app-backend
    $PROJ_DIR/$PROJ_NAME/run.sh

    PROJ_NAME=nginx
    $PROJ_DIR/$PROJ_NAME/run.sh


    echo 'http://vm-minikube:30002'
    /bin/sh -c "curl -w '\n' http://vm-minikube:30002/api/ip"
}




FUNC=$(declare -f updateHostFileForMiniKubeIP)
sudo bash -c "$FUNC; updateHostFileForMiniKubeIP $MINIKUBE_IP"



runProject


