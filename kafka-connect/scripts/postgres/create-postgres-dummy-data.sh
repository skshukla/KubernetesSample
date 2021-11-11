#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


eval $(minikube docker-env)


function freshcreateDummyTableAndData() {

  SQL_FILE_TO_EXECUTE=$1
  docker run --rm -i --name pg_dummy \
    -e PGPASSWORD=123456 \
    -v $SCRIPT_DIR/sql:/tmp/sql \
    postgres:10.4 \
    psql -h vm-kube-master-1 -p 30000 --user sachin --db mydb -f /tmp/sql/$SQL_FILE_TO_EXECUTE

}


freshcreateDummyTableAndData pg.sql