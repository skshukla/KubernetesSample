#!/usr/bin/env bash

export RETURN_VAL_IS_ZK_STARTED="false"
export RETURN_VAL_IS_ZK_HEALTHY="false"
export NSZK=zookeeper

# ----

#eval $(minikube docker-env)

# ----

function isZKStarted() {
    nodeVal=$1
    NODE_VAL="${nodeVal:-0}"
    CMD="kubectl -n $NSZK get pod zookeeper-$NODE_VAL | tail -1 | cut -d ' ' -f 1"
    RESULT=$(/bin/sh -c "$CMD")
    if [[ "$RESULT" == "zookeeper-0" ]]; then
        return 0;
    else
        return 1;
    fi
    return 1;
}


function isZKHealthy() {
    nodeVal=$1
    NODE_VAL="${nodeVal:-0}"
    CMD="kubectl -n $NSZK get pod zookeeper-$NODE_VAL | tail -1 | cut -d ' ' -f 4 | cut -d '/' -f 1"
    STATUS=$(/bin/sh -c "$CMD")
    echo 'CMD='$CMD
    IS_HEALTHY="false"
    if [[ "$STATUS" == "1" ]]; then
        return 0;
     else
        return 1;
    fi
}
