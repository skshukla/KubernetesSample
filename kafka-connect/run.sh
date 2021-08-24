#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



function runKafkaConnect() {
  echo 'Consider converting it into Kubernetes instead of just docker!!'
  docker kill kafka-connect-container || true;
  docker rm kafka-connect-container || true;
  docker run --rm -d \
    --name kafka-connect-container \
    -p 8081:8081 \
    -p 8082:8082 \
    -p 8083:8083 \
    -v $SCRIPT_DIR/config/connect-standalone.properties:/opt/bitnami/kafka/config/connect-standalone.properties \
    -v $SCRIPT_DIR/config/connect-file-source.properties:/opt/bitnami/kafka/config/connect-file-source.properties \
    -v $SCRIPT_DIR/data/test.txt:/tmp/test.txt \
    bitnami/kafka:latest /opt/bitnami/kafka/bin/connect-standalone.sh  /opt/bitnami/kafka/config/connect-standalone.properties /opt/bitnami/kafka/config/connect-file-source.properties

}


function runJDBCConnector() {

  docker cp $SCRIPT_DIR/lib/kafka-connect-jdbc-*.jar kafka-connect-container:/opt/bitnami/kafka/libs
  docker cp $SCRIPT_DIR/lib/postgresql-*.jar kafka-connect-container:/opt/bitnami/kafka/libs

#  curl -X DELETE http://localhost:8083/connectors/jdbc_source_connector_postgresql_01
  docker restart kafka-connect-container
  echo 'Would execute the connector in few seconds.....'
  sleep 10
  echo 'Going to apply the connector.....'
  curl -d @"$SCRIPT_DIR/config/postgres-connector.json" \
    -H "Content-Type: application/json" \
    -X POST http://localhost:8083/connectors
}

runKafkaConnect

sleep 5

runJDBCConnector

echo 'http://localhost:8083/connector-plugins'
echo 'docker logs -f kafka-connect-container'


#create table usr_tbl(
#id int,
#name varchar(100)
#)
#;
#insert into usr_tbl values(1, 'name-1');
#insert into usr_tbl values(2, 'name-2');
#insert into usr_tbl values(4, 'name-4');
#;
#select * from public.usr_tbl
#;


