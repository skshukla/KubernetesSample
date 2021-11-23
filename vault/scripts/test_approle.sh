#!/usr/bin/env bash

# ------------------------------------------------------------
# This program imitates the behaviour that how a Vault Admin can pass the credentials to another machine/program/bot in a secure way
# that even as Vault Admin he/she cannot see the details by using wrap/unwrap feature of Vault.
# ------------------------------------------------------------


function loginWithDefaultToken() {
  DEFAULT_TOKEN=$(vault token create -policy=default -format=json | jq -r '.auth.client_token')
  vault login $DEFAULT_TOKEN
}

function loginAsAdmin() {
    vault login -method=userpass username=admin password=admin123
}

function setUpAppRoleForTheAppAsAdmin() {
    loginAsAdmin
    vault write kv/apps/app1 name=sach description=test_description #Admin is just writing some values which app can read
    vault write kv/apps/app2 name=sach2 description2=test_description2
    echo 'This App, who is going to get this role, is allowed to read/list the data from kv/apps/app1 path but not from apps/app2 (and also read secret of its own)'
    vault policy write my-app-policy - << EOF
    path "kv/apps/app1*" {
      capabilities = [ "read", "list" ]
    }
EOF

    vault policy write my-app-policy-secret-read - << EOF
      path "auth/approle/role/my-app-role/role-id" {
        capabilities = [ "read" ]
      }
      path "auth/approle/role/my-app-role/secret-id" {
          capabilities = [ "update" ]
        }
EOF

    vault write auth/approle/role/my-app-role policies=my-app-policy,my-app-policy-secret-read

    export WRAP_TOKEN=$(vault token create -policy=my-app-policy-secret-read -wrap-ttl=60 -format=json | jq -r '.wrap_info.token')
    echo 'WRAP TOKEN='$WRAP_TOKEN', Ideally this should be sent to the App who would assume the role, for now exporting in a variable so the app can use it'
}


function appUnwrapsTheTokenSecurely() {
  loginWithDefaultToken # App must have the default role initially.
  UNWRAPPED_TOKEN=$(vault unwrap -format=json $WRAP_TOKEN  | jq -r '.auth.client_token')
  vault login $UNWRAPPED_TOKEN
  APP_ROLE_ROLE_ID=$(vault read  auth/approle/role/my-app-role/role-id -format=json | jq -r '.data.role_id')
  APP_ROLE_SECRET_ID=$(vault write -f auth/approle/role/my-app-role/secret-id -format=json | jq -r '.data.secret_id')
  echo "AppRole Role id = {$APP_ROLE_ROLE_ID}, APP_ROLE_SECRET_ID = {$APP_ROLE_SECRET_ID}"
  APP_ROLE_CLIENT_TOKEN=$(vault write -format=json auth/approle/login role_id=$APP_ROLE_ROLE_ID secret_id=$APP_ROLE_SECRET_ID | jq -r '.auth.client_token')
  vault login $APP_ROLE_CLIENT_TOKEN
}

function testAppRole() {
  echo 'By this time vault is already logged in with AppRole, lets lookup the token'
  vault token lookup
  vault read kv/apps/app1 # This should pass
  vault read kv/apps/app2 # This should fail
  echo 'The /apps/app1 should be readable but /apps/app2 should throw permission deny Error and thats perfectly Okay!!'
  echo ''
}


# -------------------------------------------------------

setUpAppRoleForTheAppAsAdmin
appUnwrapsTheTokenSecurely
testAppRole
