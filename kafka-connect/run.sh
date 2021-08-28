#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



function runKafkaConnect() {
  export NS=kafka-connect
  kubectl delete ns $NS
  kubectl -n $NS delete cm kafka-connect-cm

  kubectl -n $NS patch pvc kafka-connect-lib-standalone-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
  sleep 8
  kubectl -n $NS delete pvc kafka-connect-lib-standalone-pvc || true;

  kubectl delete pv kafka-connect-lib-standalone-pv || true;

  kubectl create ns $NS
  kubectl -n $NS create cm kafka-connect-cm --from-file=$SCRIPT_DIR/config/

  kubectl -n $NS apply -f $SCRIPT_DIR/k8/kafka-connect-standalone.yaml
}

runKafkaConnect

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


