#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


TOPIC=t-c-01-p3-r3
#TOPIC=t-sn-02-p1-r1

KAFKA_HOME=~/softwares/kafka # Your local Kafka Home installation directory

while IFS= read -r line; do
    CMD='echo '"'"$line"' | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list vm-minikube:30092 --topic "$TOPIC
    echo "$CMD"
    /bin/sh -c "$CMD"
    done < $SCRIPT_DIR/input_data/input.txt



