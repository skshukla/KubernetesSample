#!/usr/bin/env bash

# --------------------------------------------
export MONGO_NODEPORT="${MONGO_NODEPORT:-30017}"
# --------------------------------------------


V_PROJ_DIR="/home/sachin/KubernetesSample/mongodb"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..


export V_DATA_SHARE_DIR=$V_PROJ_DIR/data-share

#source $PROJ_DIR/scripts/refreshMinikubeIP.sh
#MINIKUBE_IP=$(minikube ip)
#echo 'MINIKUBE_IP='$MINIKUBE_IP
#export MINIKUBE_IP="${MINIKUBE_IP}"


START_WATCH="false"
DELETE_RESOURCES_ONLY="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"
export NS="mongo"


function helpFunction() {
    echo 'Use [-c] option to run the application as clustered'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}

function delete() {
#    eval $(minikube docker-env)

    kubectl -n $NS patch pvc mongodb-data-share-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
    sleep 8

    kubectl -n $NS delete svc mongo-svc || true;
    kubectl -n $NS delete statefulset mongo-ss
    kubectl -n $NS delete pvc mongo-persistent-storage-mongo-ss-0
    kubectl -n $NS delete pvc mongodb-data-share-pvc
    kubectl delete pv mongodb-data-share-pv

    kubectl delete ns $NS

}

function runMongo() {
    kubectl create ns $NS
    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
            echo 'MongoDB in clustered mode is yet not supported!!'
            exit 1;
        else
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/mongodb.yaml
    fi

}



while getopts "cdfhw" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) DELETE_RESOURCES_ONLY="true" ;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      h ) helpFunction ;; # Usage
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


# ------------------------------------------------------------

echo 'START_WATCH: {'$START_WATCH'}'
echo 'DELETE_RESOURCES_ONLY: {'$DELETE_RESOURCES_ONLY'}'
echo 'FORCE_CLEAN: {'$FORCE_CLEAN'}'
echo 'RUN_AS_CLUSTER: {'$RUN_AS_CLUSTER'}'

if [[ "$DELETE_RESOURCES_ONLY" == "true" ]]; then
    echo 'Going to delete the resources'
    delete
    exit 0; # In case of delete only, exit after deleting. to run the app with delete and run, us -f option to force clean.
fi

if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runMongo
else
    runMongo
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n $NS get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi

