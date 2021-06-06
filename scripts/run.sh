#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..



function getPortForService() {
  SERVICE_NAME=$1
  PORT=$(kubectl describe service ${SERVICE_NAME} | grep NodePort | tail -1 | cut -d ' ' -f2- | xargs | cut -d ' ' -f2- | cut -d '/' -f 1)
  echo 'Service {'$SERVICE_NAME'} is running on Node Port {'$PORT'}'
}

function runNginx() {
    eval $(minikube docker-env)
    kubectl delete ingress minimal-ingress || true;
    kubectl delete configmap nginx-conf || true;
    kubectl delete deployment nginx-deployment || true;
    kubectl delete service backendone-service || true;
    kubectl delete deployment backend-app-one-deployment || true;
    kubectl delete service nginx-service || true;

    $PROJ_DIR/BackendAppOne/scripts/run-docker.sh

    docker images

    kubectl apply -f $PROJ_DIR/k8scripts/backend/01_backend.yaml

    kubectl apply -f $PROJ_DIR/k8scripts/nginx/01_nginx.yaml

    kubectl apply -f $PROJ_DIR/k8scripts/ingress/01_ingress.yaml

    URL=$(minikube service nginx-service --url | tail -2)
    CMD="curl -sSX GET $URL"
    echo 'CMD='$CMD
    sleep 7
    /bin/sh -c "$CMD"

}


function runApp() {
    eval $(minikube docker-env)
    URL=$(minikube service nginx-service --url) # issue (minikube service nginx-service --url) command to know this URL
    CMD="curl -sSX POST $URL -H 'content-type: application/json' -d '{\"name\":\"sach-1\"}'"
    echo 'CMD='$CMD
    /bin/sh -c "$CMD"

    CMD="curl -w '\n' -sSX POST $URL/all | jq ."
    echo 'CMD='$CMD
    /bin/sh -c "$CMD"

    CMD="curl -w '\n' -sSX POST $URL/ip"
    echo 'CMD='$CMD
    /bin/sh -c "$CMD"
}

getPortForService nginx-service
getPortForService backendone-service
getPortForService postgres-service




runNginx

#runApp