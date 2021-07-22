#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

SERVICE_A_DIR=$PROJ_DIR/ServiceA
SERVICE_B_DIR=$PROJ_DIR/ServiceB
SERVICE_C_DIR=$PROJ_DIR/ServiceC


kubectl delete ns apps

cd $SERVICE_A_DIR
mvn clean package docker:build -DskipTests

cd $SERVICE_B_DIR
mvn clean package docker:build -DskipTests

cd $SERVICE_C_DIR
mvn clean package docker:build -DskipTests

kubectl create ns apps
kubectl apply -f $SCRIPT_DIR/k8/deploy-services.yaml

echo 'watch "kubectl -n apps get svc,deployments,pods -o wide"'
echo 'curl -X GET http://vm-minikube:30900/service/a/call/service/b/call/service/c'


