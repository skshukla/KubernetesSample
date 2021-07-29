#!/usr/bin/env bash


eval $(minikube docker-env)
MINIKUBE_IP=$(minikube ip)

eval $(minikube oc-env)
MINISHIFT_IP=$(minishift ip)

if [[ -z "$MINIKUBE_IP" ]]; then
    MINIKUBE_IP="x.x.x.x"
fi

if [[ -z "$MINISHIFT_IP" ]]; then
    MINISHIFT_IP="x.x.x.x"
fi


echo "MINIKUBE_IP=$MINIKUBE_IP, MINISHIFT_IP=$MINISHIFT_IP"

function updateHostFileForMiniKubeIP() {
    MINIKUBE_IP=$1
    MINISHIFT_IP=$2
    sed -i '' '/vm-minikube/d' /private/etc/hosts
    sed -i '' '/vm-minishift/d' /private/etc/hosts
    echo "$MINIKUBE_IP    vm-minikube" >> /private/etc/hosts
    echo "$MINISHIFT_IP    vm-minishift" >> /private/etc/hosts
    cat /private/etc/hosts
}

function refreshHostFileForMinikubeIP() {
    FUNC=$(declare -f updateHostFileForMiniKubeIP)
    sudo bash -c "$FUNC; updateHostFileForMiniKubeIP $MINIKUBE_IP $MINISHIFT_IP"
}


refreshHostFileForMinikubeIP