#!/usr/bin/env bash

export ROOT_DB_USER=root
export ROOT_DB_PWD=12345678
export DB_POD_NAME=mypg002
export PG_USER_ROLE=vaultedu
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
    echo 'Going to create a role....'
    sleep 10 # Give postgres some time to allow taking connections
    echo "create user $PG_USER_ROLE with encrypted password '123456';" | kubectl exec -i $DB_POD_NAME -- psql --db postgres --user=root
    echo 'Roles created!!'
}

function createDBCredReadPolicyAndUser() {
  vault policy delete db-cred-staticread || true;
  vault policy write db-cred-staticread - << EOF
  path "database/static-creds/education" {
    capabilities = [ "read" ]
  }
EOF
  vault policy read db-cred-staticread
  vault write auth/userpass/users/vault-edu-user password=123456 policies=db-cred-staticread
}


function setupPostgresDynamicCredConfig() {
vault write database/config/postgresql \
     plugin_name=postgresql-database-plugin \
     connection_url="postgresql://{{username}}:{{password}}@kube0:${PG_NODE_PORT}/postgres?sslmode=disable" \
     allowed_roles="*" \
     username="$ROOT_DB_USER" \
     password="$ROOT_DB_PWD"

vault write -force database/rotate-root/postgresql


tee rotation.sql <<EOF
ALTER USER "{{name}}" WITH PASSWORD '{{password}}';
EOF


vault write database/static-roles/education \
    db_name=postgresql \
    rotation_statements=@rotation.sql \
    username="vaultedu" \
    rotation_period=60
}


function testResult() {
    vault login -method=userpass username=vault-edu-user password=123456
    echo 'Readonly Role details as below.....'
    INFO=$(vault read database/static-creds/education -format=json)
    echo 'User Info : '
    echo $INFO | jq .
}
# ---------------------

runPGDatabase
vault login -method=userpass username=admin password=admin123
createDBCredReadPolicyAndUser
setupPostgresDynamicCredConfig

testResult

sleep 10
testResult

vault login -method=userpass username=admin password=admin123
vault write -f database/rotate-role/education

testResult