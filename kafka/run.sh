#!/usr/bin/env bash

# --------------------------------------------
export KUBE_MASTER_IP=192.168.10.101
export KAFKA_NODEPORT_0="${KAFKA_NODEPORT_0:-30092}"
export KAFKA_NODEPORT_SECURE_0="${KAFKA_NODEPORT_SECURE_0:-30192}"
export KAFKA_NODEPORT_1="${KAFKA_NODEPORT_1:-30093}"
export KAFKA_NODEPORT_2="${KAFKA_NODEPORT_2:-30094}"
# --------------------------------------------


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR/..

export KAFKA_VOL_LOC=${SCRIPT_DIR}/kafka-data-host/data

START_WATCH="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"
RUN_IN_SECURE_MODE="false"


function createStoresData() {
  rm -rf ${KAFKA_VOL_LOC} && mkdir -p ${KAFKA_VOL_LOC}/ssl
  openssl genrsa -out ${KAFKA_VOL_LOC}/root.key
  echo -e "SG\nSingapore\nSingapore\nMYCOMP\ndev\n${MINIKUBE_IP}\na@a.com" | openssl req -new -x509 -key ${KAFKA_VOL_LOC}/root.key -out ${KAFKA_VOL_LOC}/root.crt
  echo -e '123456\n123456\nyes' | keytool -keystore ${KAFKA_VOL_LOC}/kafka.truststore.jks -alias CARoot -import -file ${KAFKA_VOL_LOC}/root.crt
  echo -e '123456\n123456\nSachin Shukla\ndev\nMYCOMP\nSingapore\nSingapore\nSG\nyes' | keytool -keystore ${KAFKA_VOL_LOC}/kafka.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:vm-minikube
  echo -e '123456' | keytool -keystore ${KAFKA_VOL_LOC}/kafka.keystore.jks -alias localhost -certreq -file ${KAFKA_VOL_LOC}/kafka.unsigned.crt
  openssl x509 -req -CA ${KAFKA_VOL_LOC}/root.crt -CAkey ${KAFKA_VOL_LOC}/root.key -in ${KAFKA_VOL_LOC}/kafka.unsigned.crt -out ${KAFKA_VOL_LOC}/kafka.signed.crt -days 365 -CAcreateserial
  echo -e '123456\nyes' | keytool -keystore ${KAFKA_VOL_LOC}/kafka.keystore.jks -alias CARoot -import -file ${KAFKA_VOL_LOC}/root.crt
  echo '123456' | keytool -keystore ${KAFKA_VOL_LOC}/kafka.keystore.jks -alias localhost -import -file ${KAFKA_VOL_LOC}/kafka.signed.crt

echo "bootstrap.servers=${MINIKUBE_IP}:${KAFKA_NODEPORT_SECURE_0}
security.protocol=SSL
ssl.truststore.location=${SCRIPT_DIR}/kafka-data-host/data/kafka.truststore.jks
ssl.truststore.password=123456
ssl.keystore.location=${SCRIPT_DIR}/kafka-data-host/data/kafka.keystore.jks
ssl.keystore.password=123456
ssl.key.password=123456
ssl.endpoint.identification.algorithm=

">${KAFKA_VOL_LOC}/ssl/client-ssl-host.properties
}

function createStoresData2() {
rm -rf ${KAFKA_VOL_LOC}/ssl && mkdir -p ${KAFKA_VOL_LOC}/ssl
echo "bootstrap.servers=localhost:9093
security.protocol=SSL
ssl.truststore.location=/bitnami/kafka/config/certs/kafka.truststore.jks
ssl.truststore.password=123456
ssl.keystore.location=/bitnami/kafka/config/certs/kafka.keystore.jks
ssl.keystore.password=123456
ssl.key.password=123456

">${KAFKA_VOL_LOC}/ssl/client-ssl-local.properties

echo "bootstrap.servers=192.168.99.119:9093
security.protocol=SSL
ssl.truststore.location=/Users/sachin/workspace/skshukla/KubernetesSample/kafka/kafka-data-host/data/kafka.truststore.jks
ssl.truststore.password=123456
ssl.keystore.location=/Users/sachin/workspace/skshukla/KubernetesSample/kafka/kafka-data-host/data/kafka.keystore.jks
ssl.keystore.password=123456
ssl.key.password=123456

">${KAFKA_VOL_LOC}/ssl/client-ssl-host.properties
}



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
    echo 'Use [-s] option to run the application using secure mode (SSL)'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-w] option to start watching the app at last'
    echo 'Use [-x] Use this Extended Help option to get kafka commands related help'
    exit 0;
}


function waitForZKToUpAndRunning {
    source $PROJ_DIR/zookeeper/health.sh
    if isZKStarted; then
        echo 'ZK has already been started.'
     else
        echo 'Seems ZK has not been running, starting ZK Cluster.....'
        echo '-----'
        $PROJ_DIR/zookeeper/run.sh -f
    fi

#     --------

    echo 'Going to check the status of ZK health!!!!'
    i=1
    TIMEOUT=300
    INTERVAL=10
    ATTEMPT_COUNT=$(($TIMEOUT/$INTERVAL))
    echo "TIMEOUT=$TIMEOUT, INTERVAL=$INTERVAL, ATTEMPT_COUNT=$ATTEMPT_COUNT"

        while [ "$i" -le "$ATTEMPT_COUNT" ]; do
            if [ "$ATTEMPT_COUNT" = "$i" ]; then
                echo 'Reached Time Out!!!!'
                exit 0;
            fi

            if isZKHealthy; then
                echo 'ZK Node is healthy..'
                return 0;
            fi
            echo '['$i'] - ZK not available yet, would be attempted again in '$INTERVAL' seconds'
            sleep $INTERVAL
            i=$(($i + 1))
        done

}


function delete() {
#    eval $(minikube docker-env)
    kubectl -n kafka delete statefulset.apps/kafka-d-0 service/kafka-0 persistentvolumeclaim/kafka-data-kafka-d-0-0 persistentvolumeclaim/my-hostpath-volume-kafka-d-0-0
    kubectl delete pv kafka-pv || true;
    kubectl delete ns kafka
    kubectl delete pv $(kubectl get pv | grep kafka | cut -d ' ' -f 1)
    kubectl delete svc kafdrop
    kubectl delete deployment.apps/kafdrop
}

function runKafDrop() {
    rm -rf /tmp/kafdrop && mkdir -p /tmp/kafdrop &&  cd /tmp/kafdrop && git clone https://github.com/obsidiandynamics/kafdrop && cd kafdrop
    KAFDROP_BROKER_CONNECT_STR="${KUBE_MASTER_IP}:${KAFKA_NODEPORT_0}"
#    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
#      KAFDROP_BROKER_CONNECT_STR="${KUBE_MASTER_IP}:${KAFKA_NODEPORT_0},${KUBE_MASTER_IP}:${KAFKA_NODEPORT_1},${KUBE_MASTER_IP}:${KAFKA_NODEPORT_2}"
#    fi
    echo 'KAFDROP_BROKER_CONNECT_STR='$KAFDROP_BROKER_CONNECT_STR
    helm upgrade -i kafdrop chart --set image.tag=3.27.0 --set kafka.brokerConnect="${KAFDROP_BROKER_CONNECT_STR}" --set server.servlet.contextPath="/"  --set jvm.opts="-Xms32M -Xmx64M"
    export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services kafdrop)
    export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    echo "Access KafDrop at : http://$NODE_IP:$NODE_PORT"
}

function runKafka() {
#    eval $(minikube docker-env)
    kubectl create ns kafka
    echo 'Going to create the kafka cluster under node : '$zk_node

    if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
            echo 'Running in cluster mode...'
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka.yaml
      elif [[ "${RUN_IN_SECURE_MODE}" == "true" ]]; then
            echo 'Running the application in secure mode.....'
            createStoresData
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka-volume.yaml
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka-singlenode-secure.yaml
            echo "Execute below command to securely connect to Kafka Broker
            $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list ${MINIKUBE_IP}:${KAFKA_NODEPORT_SECURE_0} --topic t01 --producer.config ${SCRIPT_DIR}/kafka-data-host/data/ssl/client-ssl-host.properties
            $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server ${MINIKUBE_IP}:${KAFKA_NODEPORT_SECURE_0} --topic t01  --consumer.config ${SCRIPT_DIR}/kafka-data-host/data/ssl/client-ssl-host.properties --from-beginning
            "
      else
            echo 'Running stand alone.....'
            $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/kafka-singlenode.yaml
    fi

    kafkaCommandsHelp
    runKafDrop
}


while getopts "cdfhswx" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      s ) RUN_IN_SECURE_MODE="true" ;;
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
    waitForZKToUpAndRunning
    runKafka
else
    runKafka
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n kafka get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi

