#!/usr/bin/env bash

# ---------------------------------------------------------------------
DEPLOY_POSTGRES="false"
DEPLOY_NGINX="false"
DEPLOY_API_SERVICE="false"
DEPLOY_ZOOKEEPER="false"
DEPLOY_REDIS="true"

# ---------------------------------------------------------------------
export POSTGRES_NODEPORT=30000
export NGINX_NODEPORT=30001
export API_SERVICE_NODEPORT=30002
export ZK_NODEPORT=30003
export REDIS_PRIMARY_NODEPORT=30010
export REDIS_REPLICA_NODEPORT=30011
# ---------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$SCRIPT_DIR

source $PROJ_DIR/scripts/util.sh

function runProject() {

    if [[ "$DEPLOY_POSTGRES" == "true" ]]; then
        $PROJ_DIR/postgres/run.sh
    fi

    if [[ "$DEPLOY_API_SERVICE" == "true" ]]; then
        $PROJ_DIR/app-backend/run.sh
    fi

    if [[ "$DEPLOY_NGINX" == "true" ]]; then
        $PROJ_DIR/nginx/run.sh
    fi

    if [[ "$DEPLOY_ZOOKEEPER" == "true" ]]; then
        $PROJ_DIR/zookeeper/run.sh
    fi

    if [[ "$DEPLOY_REDIS" == "true" ]]; then
        $PROJ_DIR/redis/run.sh
    fi

}


runProject


