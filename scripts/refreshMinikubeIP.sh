#!/usr/bin/env bash


eval $(minikube docker-env)
MINIKUBE_IP=$(minikube ip)

function updateHostFileForMiniKubeIP() {
    MINIKUBE_IP=$1
    sed -i '' '/vm-minikube/d' /private/etc/hosts
    echo "$MINIKUBE_IP    vm-minikube" >> /private/etc/hosts
    cat /private/etc/hosts
}

function refreshHostFileForMinikubeIP() {
    FUNC=$(declare -f updateHostFileForMiniKubeIP)
    sudo bash -c "$FUNC; updateHostFileForMiniKubeIP $MINIKUBE_IP"
}


refreshHostFileForMinikubeIP