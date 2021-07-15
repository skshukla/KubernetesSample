#!/usr/bin/env bash

# --------------------------------------------
export KAFKA_NODEPORT="${KAFKA_NODEPORT:-30092}"
export KAFKA_NODEPORT_0="${KAFKA_NODEPORT_0:-30092}"
export KAFKA_NODEPORT_1="${KAFKA_NODEPORT_1:-30093}"
export KAFKA_NODEPORT_2="${KAFKA_NODEPORT_2:-30094}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

source $PROJ_DIR/scripts/refreshMinikubeIP.sh
MINIKUBE_IP=$(minikube ip)
echo 'MINIKUBE_IP='$MINIKUBE_IP
export MINIKUBE_IP="${MINIKUBE_IP}"


START_WATCH="false"
DELETE_RESOURCES_ONLY="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"


function helpFunction() {
    echo 'Use [-c] option to run the application as clustered'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}

function delete() {
    eval $(minikube docker-env)
    kubectl delete ns kafka
}

function runKafka() {
    eval $(minikube docker-env)
    kubectl create ns kafka
    export zk_node=n_$(date +%s)
    echo 'Going to create the kafka cluster under node : '$zk_node

    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka.yaml
        else
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka-singlenode.yaml
    fi

    echo 'Use below command for console producer and consumer once, ssh into the pod.
    /opt/bitnami/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic asdf  \n
    /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic asdf  --from-beginning
    '
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
    runKafka
else
    runKafka
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n kafka get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi

