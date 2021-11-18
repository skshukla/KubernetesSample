#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

V_HOME_DIR="/home/sachin"
V_PROJ_DIR=$V_HOME_DIR/KubernetesSample/vault


PROJ_DIR=$SCRIPT_DIR/..

export NS=vault
export VAULT_NODE_PORT=30820
export V_VAULT_DATA_SHARE_DIR=${V_PROJ_DIR}/data-share


START_WATCH="false"
FORCE_CLEAN="false"
RUN_AS_CLUSTER="false"


function helpFunction() {
    echo 'Use [-c] option to run the application as clustered'
    echo 'Use [-d] option to delete only the resources and exit'
    echo 'Use [-f] option to delete and clean the resouces previously run (should be used for a fresh clean run)'
    echo 'Use [-h] option to see the help'
    echo 'Use [-x] option to see extended help'
    echo 'Use [-w] option to start watching the app at last'
    exit 0;
}


function extendedHelp() {
    echo "
    NEED TO WRITE
    ------------------------------------------------------------------------------
    "
}

function delete() {
  kubectl delete clusterrolebinding vault-server-binding

  kubectl -n $NS patch pvc vault-pvc -p '{"metadata":{"finalizers": []}}' --type=merge || true;
  sleep 8
  kubectl -n $NS delete pvc vault-pvc || true;
  kubectl -n $NS delete pv vault-pv || true;

  kubectl delete ns $NS
}

function runVault() {
  kubectl create ns $NS
  kubectl -n $NS create cm vault-config --from-file=$SCRIPT_DIR/k8/config/extraconfig-from-values.hcl

  if [[ "${RUN_AS_CLUSTER}" == "true" ]]; then
          echo 'Cluster setup is NOT supported at the moment!!!!'
          exit 1;
      else
          $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/k8/vault-pv.yaml
          $PROJ_DIR/scripts/kubectl_advance -a -f $SCRIPT_DIR/k8/vault.yaml
#          kubectl apply -f $SCRIPT_DIR/k8/vault.yaml
  fi

  echo "

  *****************************************************************************************
  Issue this command to see some basic logs and for token details.
  Ideally Root token logs to be deleted and token needs to be revoked once there are other auth mechanism.
  \"kubectl -n $NS exec -it pod/vault-0 -- cat /tmp/log.out\"
  If all goes good, you can login to Vault at http://kube0:${VAULT_NODE_PORT} with credentials as admin/admin123.....
  *****************************************************************************************
  "

}

no_args="true"
while getopts "cdfhwx" opt
do
   case "$opt" in
      c ) RUN_AS_CLUSTER="true" ;;
      d ) (delete || true) && exit 0;;
      f ) FORCE_CLEAN="true" ;;
      w ) START_WATCH="true" ;;
      x ) extendedHelp && exit 0 ;;
      h ) helpFunction && exit 0;; # Usage
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
   no_args="false"
done

if [[ "$no_args" == "true" ]]; then
  helpFunction && exit 1;
fi

if [[ "$FORCE_CLEAN" == "true" ]]; then
    delete
    runVault
else
    runVault
fi


if [[ "$START_WATCH" == "true" ]]; then
    watch "kubectl -n $NS get svc,deployments,pods -o wide"
fi


