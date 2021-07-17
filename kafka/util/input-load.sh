#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


TOPIC=t1-p3-r2
KAFKA_HOME=~/softwares/kafka

while IFS= read -r line; do
    CMD='echo '"'"$line"' | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list vm-minikube:30092 --topic "$TOPIC
    echo "$CMD"
    /bin/sh -c "$CMD"
    done < $SCRIPT_DIR/input_data/input.txt



