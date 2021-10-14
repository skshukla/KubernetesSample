#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJ_DIR=$SCRIPT_DIR/..

export NS=kafka-connect
export DATA_SHARE_DIR=$SCRIPT_DIR/data-share

START_WATCH="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"


function helpFunction() {
    echo 'Use [-c] option to run the application as clustered'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-x] option to see extended help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}


function extendedHelp() {
    echo "
    [BROWSE CONNECTORS]: http://vm-minikube:30083/connectors
    [BROWSE CONNECTOR PLUGINS]: http://vm-minikube:30083/connector-plugins
    [APPLY CONNECTORS]: curl -d @$DATA_SHARE_DIR/config/postgres-connector.json \\
                    -H 'Content-Type: application/json' \\
                    -X POST http://vm-minikube:30083/connectors
    [DELETE CONNECTORS]: curl -X DELETE http://vm-minikube:30083/connectors/<connector-name>
    ------------------------------------------------------------------------------
    "
}

function delete() {
  kubectl delete ns $NS
  kubectl -n $NS delete cm kafka-connect-cm
  kubectl -n $NS patch pvc kafka-connect-data-share-standalone-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
  sleep 8
  kubectl -n $NS delete pvc kafka-connect-data-share-standalone-pvc || true;
  kubectl delete pv kafka-connect-data-share-standalone-pv || true;
}

function runKafkaConnect() {
  echo '**** config/connect-standalone.properties file uses Kafka Broker details, MAKE SURE THAT IS CORRECT with right IP address value of vm-minikube ****'
  echo '****'
  kubectl create ns $NS
  kubectl -n $NS create cm kafka-connect-cm --from-file=$SCRIPT_DIR/config/

  if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
          echo 'Cluster setup is NOT supported at the moment!!!!'
          exit 1;
      else
          $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/k8/kafka-connect-standalone.yaml
  fi

}

no_args="true"
while getopts "cdfhwx" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      x ) extendedHelp && exit 0 ;;
      h ) helpFunction && exit 0;; # Usage
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
   no_args="false"
done

if [[ "$no_args" == "true" ]]; then
  helpFunction && exit 1;
fi

if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runKafkaConnect
else
    runKafkaConnect
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n $NS get svc,deployments,pods -o wide"
fi


