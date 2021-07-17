#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


kubectl -n kafka exec -t pod/kafka-d-0-0 -- rm -rf /bitnami/kafka/data/input_data

kubectl -n kafka cp $SCRIPT_DIR/input_data kafka-d-0-0:/bitnami/kafka/data


kubectl -n kafka exec -t pod/kafka-d-0-0 -- /bitnami/kafka/data/input_data/load.sh






