#!/usr/bin/env bash


DEPLOY_POSTGRES="true"
DEPLOY_NGINX="true"
DEPLOY_API_SERVICE="true"
DEPLOY_ZOOKEEPER="true"


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

}


runProject


