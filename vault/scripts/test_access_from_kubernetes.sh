#!/usr/bin/env bash

export SA_NAME=vault-sa
export KUBERNETES_HOST=https://192.168.10.100:6443

# ------------------------------------------------------------

function setUpAtKubernetesSide() {
    kubectl delete sa $SA_NAME || true kubectl delete clusterrolebinding role-tokenreview-binding || true && kubectl create sa $SA_NAME
    export TOKEN_NAME=$(kubectl get sa $SA_NAME -o json | jq -r '.secrets[0].name')
    export TOKEN_VAL=$(kubectl get secrets $TOKEN_NAME -o json | jq -r '.data.token' | base64 --decode)
    echo "Token name is : $TOKEN_NAME"
    echo "Token Value is : $TOKEN_VAL"

tee abc.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: $SA_NAME
    namespace: default
EOF

  kubectl apply -f abc.yaml

}


function prepareDataForAccess() {
    vault login -method=userpass username=admin password=admin123
    vault write kv/apps/test-kube-path name=sachin description=Test_Description
    vault write kv/apps/test-kube-path2 name=sachin2 description=Test_Description2
    vault write kv/apps/test-kube-path3 name=sachin3 description=Test_Description3

    vault policy write test-policy - << EOF
    path "kv/apps/test-kube-path*" {
      capabilities = [ "read" ]
    }
    path "kv/apps/test-kube-path2" {
          capabilities = [ "deny" ]
    }
EOF
}

function setupVaultForKubeAuth() {
    vault login -method=userpass username=admin password=admin123
    vault secrets enable kv || true;

    scp sachin@kube0:/etc/kubernetes/pki/ca.crt /tmp/ca.crt

    vault write auth/kubernetes/config \
        token_reviewer_jwt="$TOKEN_VAL" \
        kubernetes_host="$KUBERNETES_HOST" \
        kubernetes_ca_cert=@/tmp/ca.crt

    vault write auth/kubernetes/role/demo \
        bound_service_account_names="$SA_NAME" \
        bound_service_account_namespaces=default \
        policies=default,test-policy \
        ttl=1h
}

function testAuthenticationUsingJwt() {
    echo "*******************************
    Issue below command to authenticate Vault using Service Account JWT for testing, in Real world, the container running with this service account would have this JWT value in the volume mounts.
    vault write auth/kubernetes/login role=demo jwt=$TOKEN_VAL
    Use token to read the values, you can read with the token only the value at test-kube-path/test-kube-path3 but not at test-kube-path2:
    vault read kv/apps/test-kube-path
    vault read kv/apps/test-kube-path2
    vault read kv/apps/test-kube-path3
    "
}


# -------------------------------------------------------

setUpAtKubernetesSide
prepareDataForAccess
setupVaultForKubeAuth
testAuthenticationUsingJwt
