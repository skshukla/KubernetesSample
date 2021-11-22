#!/usr/bin/env bash

export ROOT_DB_USER=root
export ROOT_DB_PWD=12345678
export DB_POD_NAME=mypg001

#---------------------------------------------

function runPGDatabase() {
    kubectl delete pod $DB_POD_NAME || true;
    kubectl delete svc $DB_POD_NAME || true;
    kubectl run $DB_POD_NAME --image=postgres --env=POSTGRES_USER=$ROOT_DB_USER --env=POSTGRES_PASSWORD=$ROOT_DB_PWD
    kubectl expose pod $DB_POD_NAME --type=NodePort --port=5432
    export PG_NODE_PORT=$(kubectl get svc $DB_POD_NAME -o=jsonpath='{.spec.ports[0].nodePort}')
    echo 'postgres is running at port: '$PG_NODE_PORT
    echo "Check db as: psql -h kube0 -p ${PG_NODE_PORT} --db=postgres --user=$ROOT_DB_USER"
    echo "Enter the password as: $ROOT_DB_PWD"
    echo ""
}

function createDBCredReadPolicyAndUser() {
  vault policy delete db-cred-readonly || true;
  vault policy write db-cred-readonly - << EOF
  path "database/creds/readonly" {
    capabilities = [ "read" ]
  }
EOF
  vault policy read db-cred-readonly
  vault write auth/userpass/users/pg-readonly password=123456 policies=db-cred-readonly
}


function setupPostgresDynamicCredConfig() {
vault write database/config/postgresql \
     plugin_name=postgresql-database-plugin \
     connection_url="postgresql://{{username}}:{{password}}@kube0:${PG_NODE_PORT}/postgres?sslmode=disable" \
     allowed_roles=readonly \
     username="$ROOT_DB_USER" \
     password="$ROOT_DB_PWD"

tee readonly.sql <<EOF
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
EOF

vault write database/roles/readonly \
      db_name=postgresql \
      creation_statements=@readonly.sql \
      default_ttl=1h \
      max_ttl=24h
}


function testResult() {
    vault login -method=userpass username=pg-readonly password=123456
    echo 'Readonly Role details as below.....'
    INFO=$(vault read database/creds/readonly -format=json)
    echo 'User Info : '
    echo $INFO | jq .
    USERNAME=$(echo $INFO | jq -r .data.username)
    PASSWORD=$(echo $INFO | jq -r .data.password)
    echo "************************* Use this command to login *************************
    psql -h kube0 -p $PG_NODE_PORT --db=postgres --user=$USERNAME
    And once done, use password: $PASSWORD"
}

# ---------------------

runPGDatabase
sleep 10 # Give postgres some time to allow taking connections
vault login -method=userpass username=admin password=admin123
createDBCredReadPolicyAndUser
setupPostgresDynamicCredConfig

testResult


