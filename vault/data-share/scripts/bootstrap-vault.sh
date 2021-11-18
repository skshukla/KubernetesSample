#!/usr/bin/env sh

DATA_SHARE_DIR=/vault/data-share

export VAULT_ADDR=http://127.0.0.1:8200

function initVault() {
  vault operator init > /tmp/out.txt
  export KEY_1=$(cat /tmp/out.txt | grep "Key 1" | cut -d ' ' -f 4)
  export KEY_2=$(cat /tmp/out.txt | grep "Key 2" | cut -d ' ' -f 4)
  export KEY_3=$(cat /tmp/out.txt | grep "Key 3" | cut -d ' ' -f 4)
  export ROOT_TOKEN=$(cat /tmp/out.txt | grep "Root Token" | cut -d ':' -f 2 | cut -d ' ' -f 2)
}

function unsealVault() {
    vault operator unseal $KEY_1
    vault operator unseal $KEY_2
    vault operator unseal $KEY_3
}

function createAdminUser() {
    vault login $ROOT_TOKEN
    vault auth enable userpass
    vault policy write admin ${DATA_SHARE_DIR}/config/admin-policy.hcl
    vault write auth/userpass/users/admin password="admin123" policies=admin
    echo "Admin user has been created for vault..with username {admin}, password {admin123}"
    echo "KEY_1={$KEY_1}, KEY_2={$KEY_2}, KEY_3={$KEY_3}, ROOT_TOKEN={$ROOT_TOKEN}"
}

function cleanup() {
#    vault token revoke $ROOT_TOKEN # Idieally root token needs to be reoved in Prod, okay to keep only for testing
    rm -rf /tmp/out.txt
    unset KEY_1
    unset KEY_2
    unset KEY_3
    unset ROOT_TOKEN
}

sleep 5

initVault
unsealVault
createAdminUser
cleanup



