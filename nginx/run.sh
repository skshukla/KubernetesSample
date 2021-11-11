#!/usr/bin/env bash

# --------------------------------------------
CONTAINER_RUNTIME_DIR_NAME=.contents-runtime
export NGINX_NODEPORT="${NGINX_NODEPORT:-30001}"
export NS=nginx
# --------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

V_PROJ_DIR="/home/sachin/KubernetesSample/nginx"

export RUNTIME_CONTENTS_DIR=$SCRIPT_DIR/$CONTAINER_RUNTIME_DIR_NAME
export V_RUNTIME_CONTENTS_DIR=${V_PROJ_DIR}/$CONTAINER_RUNTIME_DIR_NAME
export NGINX_CONFIG_FILE_PATH=${SCRIPT_DIR}/config/nginx.conf


function delete() {
    kubectl -n $NS delete configmap/nginx-conf deployment.apps/nginx-deployment service/nginx-service || true;
    kubectl -n $NS patch pvc nginx-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8
    kubectl -n $NS delete persistentvolumeclaim/nginx-pvc persistentvolume/nginx-pv || true;
    kubectl delete ns $NS
}

function createNginx() {
      kubectl create ns $NS
      rm -rf $RUNTIME_CONTENTS_DIR && mkdir -p $RUNTIME_CONTENTS_DIR
      cp -v -rf $SCRIPT_DIR/contents-src/* $RUNTIME_CONTENTS_DIR
      kubectl -n $NS create cm nginx-conf --from-file=$NGINX_CONFIG_FILE_PATH
      $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/nginx.yaml
      sleep 6
#    $PROJ_DIR/app-backend/run.sh
      echo "curl -w '\n' http://vm-kube-master-1:${NGINX_NODEPORT}"
}

function runNginx() {
    delete
    createNginx
    watch "kubectl -n $NS get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels -l app=nginx"
}

runNginx