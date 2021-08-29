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
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
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
  echo '**** config/connect-standalone.properties file uses Kafka Broker details, MAKE SURE THAT IS CORRECT ****'
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


while getopts "cdfhwx" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      h ) helpFunction && exit 0;; # Usage
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runKafkaConnect
else
    runKafkaConnect
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n $NS get svc,deployments,statefulset,pods,pv,pvc -o wide --show-labels"
fi


#function runJDBCConnector() {
#
#  docker cp $SCRIPT_DIR/lib/kafka-connect-jdbc-*.jar kafka-connect-container:/opt/bitnami/kafka/libs
#  docker cp $SCRIPT_DIR/lib/postgresql-*.jar kafka-connect-container:/opt/bitnami/kafka/libs
#
##  curl -X DELETE http://localhost:8083/connectors/jdbc_source_connector_postgresql_01
#  docker restart kafka-connect-container
#  echo 'Would execute the connector in few seconds.....'
#  sleep 10
#  echo 'Going to apply the connector.....'
#  curl -d @"$SCRIPT_DIR/config/postgres-connector.json" \
#    -H "Content-Type: application/json" \
#    -X POST http://localhost:8083/connectors
#}
#
#runKafkaConnect
#
#sleep 5
#
#runJDBCConnector
##
#echo 'http://localhost:8083/connector-plugins'
#echo 'docker logs -f kafka-connect-container'


#create table usr_tbl(
#id int SERIAL PRIMARY KEY,
#name varchar(100)
#)
#;
#insert into usr_tbl values(1, 'name-1');
#insert into usr_tbl values(2, 'name-2');
#insert into usr_tbl values(4, 'name-4');
#;
#select * from public.usr_tbl
#;


