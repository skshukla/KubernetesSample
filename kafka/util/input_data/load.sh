#!/usr/bin/env bash


TOPIC=AAAA

while IFS= read -r line; do
    echo "line=$line"
    echo "$line" | /opt/bitnami/kafka/bin/kafka-console-producer.sh --broker-list localhost:30092 --topic $TOPIC
    done < /bitnami/kafka/data/input_data/input.txt
