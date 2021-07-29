#!/usr/bin/env bash

# --------------------------------------------
export KAFKA_NODEPORT_0="${KAFKA_NODEPORT_0:-30092}"
export KAFKA_NODEPORT_1="${KAFKA_NODEPORT_1:-30093}"
export KAFKA_NODEPORT_2="${KAFKA_NODEPORT_2:-30094}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

START_WATCH="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"


function kafkaCommandsHelp() {
    echo "Use below command for console producer and consumer once, ssh into the pod.
    ------------------------------------------------------------------------------
    kubectl -n kafka exec -it kafka-d-0-0 -- /bin/sh
    ---
    /opt/bitnami/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper-service.zookeeper.svc.cluster.local:2181/${zk_node} --replication-factor 1 --partitions 3 --topic mytopic-01
    /opt/bitnami/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper-service.zookeeper.svc.cluster.local:2181/${zk_node} --replication-factor 3 --partitions 3 --topic my-compacted-topic-01 --config cleanup.policy=compact  --config min.cleanable.dirty.ratio=0.01  --config segment.ms=100 --config delete.retention.ms=100
    /opt/bitnami/kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper-service.zookeeper.svc.cluster.local:2181/${zk_node} --topic t-c-01-p1-r3
    /opt/bitnami/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper-service.zookeeper.svc.cluster.local:2181/${zk_node}
    /opt/bitnami/kafka/bin/kafka-topics.sh --zookeeper zookeeper-service.zookeeper.svc.cluster.local:2181/${zk_node} --alter --topic t-c-01-p1-r3 --partitions 16
    /opt/bitnami/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic t-c-01-p1-r3
    /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic t-c-01-p1-r3  --from-beginning
    /opt/bitnami/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic t-c-01-p1-r3  --from-beginning --property print.key=true --property key.separator=" : "
    --
    Furthermore, Some useful commands: https://github.com/skshukla/infra/blob/dev/run_kafka/Readme.md
    ------------------------------------------------------------------------------
    "
}

function helpFunction() {
    echo 'Use [-c] option to run the application as clustered'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    echo 'Use [-x] Use this Extended Help option to get kafka commands related help'
    exit 0;
}

function delete() {
    eval $(minikube docker-env)
    kubectl delete ns kafka

    kubectl delete svc kafdrop
    kubectl delete deployment.apps/kafdrop
}

function runKafDrop() {
    rm -rf /tmp/kafdrop && mkdir -p /tmp/kafdrop &&  cd /tmp/kafdrop && git clone https://github.com/obsidiandynamics/kafdrop && cd kafdrop
    helm upgrade -i kafdrop chart --set image.tag=3.27.0 --set kafka.brokerConnect=${MINIKUBE_IP}:${KAFKA_NODEPORT_0} --set server.servlet.contextPath="/"  --set jvm.opts="-Xms32M -Xmx64M"
    export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services kafdrop)
    export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    echo "Access KafDrop at : http://$NODE_IP:$NODE_PORT"
}

function runKafka() {
    eval $(minikube docker-env)
    kubectl create ns kafka
    echo 'Going to create the kafka cluster under node : '$zk_node

    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka.yaml
        else
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka-singlenode.yaml
    fi

    kafkaCommandsHelp
    runKafDrop
}


while getopts "cdfhwx" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      h ) helpFunction && exit 0;; # Usage
      x ) kafkaCommandsHelp && exit 0;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


source $PROJ_DIR/scripts/refreshMinikubeIP.sh
MINIKUBE_IP=$(minikube ip)
echo 'MINIKUBE_IP='$MINIKUBE_IP
export MINIKUBE_IP="${MINIKUBE_IP}"
export zk_node=n_$(date +%s)

# ------------------------------------------------------------

echo 'START_WATCH: {'$START_WATCH'}'
echo 'FORCE_CLEAN: {'$FORCE_CLEAN'}'
echo 'RUN_AS_CLUSTER: {'$RUN_AS_CLUSTER'}'



if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runKafka
else
    runKafka
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n kafka get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi

