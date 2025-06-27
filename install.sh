#!/bin/bash

set -x
set -eo pipefail

if [[ "${BUFSTREAM_VERSION}" == "" ]] ; then
  echo "\$BUFSTREAM_VERSION must be defined to the desired bufstream version."
  exit 1
fi

if [[ "${BUFSTREAM_CLOUD}" == "" ]] ; then
  echo "\$BUFSTREAM_CLOUD must be defined to `gcp` or `aws`."
  exit 1
fi

if [[ "${BUFSTREAM_TFVARS}" == "" ]] ; then
  echo "\$BUFSTREAM_TFVARS must be defined to a .tfvars file."
  exit 1
fi

case "${BUFSTREAM_METADATA}" in
"postgres" | "etcd")
  ;;
"spanner")
  if [[ "$BUFSTREAM_CLOUD" != "gcp" ]] ; then
    echo "'spanner' is only available in gcp"
    exit 1
  fi
  ;;
*)
  echo "\$BUFSTREAM_METADATA must be defined to 'postgres' or 'etcd'. For gcp, 'spanner' is also available"
  exit 1
  ;;
esac

BUFSTREAM_TFVARS=$(realpath "${BUFSTREAM_TFVARS}")

CONFIG_GEN_PATH=$PWD/gen

pushd "${BUFSTREAM_CLOUD}"

echo "Applying Terraform..."
 TF_VAR_generate_config_files_path="${CONFIG_GEN_PATH}" \
  TF_VAR_bufstream_metadata="${BUFSTREAM_METADATA}" \
  terraform init \
  --var-file "${BUFSTREAM_TFVARS}" \
  --var "bufstream_k8s_namespace=${BUFSTREAM_NAMESPACE:-bufstream}"

 TF_VAR_generate_config_files_path="${CONFIG_GEN_PATH}" \
  TF_VAR_bufstream_metadata="${BUFSTREAM_METADATA}" \
  terraform apply \
  --var-file "${BUFSTREAM_TFVARS}" \
  --var "bufstream_k8s_namespace=${BUFSTREAM_NAMESPACE:-bufstream}"

# AWS does not come with a working storage class even on automode.
if [[ "${BUFSTREAM_CLOUD}" == "aws" || "${BUFSTREAM_CLOUD}" == "azure" ]] ; then
  echo "Creating ${BUFSTREAM_CLOUD} storage class..."
  kubectl \
      --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
      apply -f "../config/${BUFSTREAM_CLOUD}-storage-class.yaml"
fi

echo "Create namespace..."
# Use dry run + apply to ignore existing namespace.
kubectl \
  --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  create namespace "${BUFSTREAM_NAMESPACE:-bufstream}" --dry-run=client -o yaml \
  | kubectl \
    --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
    apply -f -

if [[ "${BUFSTREAM_METADATA}" == "postgres" ]] ; then
  echo "Running Postgres setup script..."
  KUBECONFIG="${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  NAMESPACE="${BUFSTREAM_NAMESPACE:-bufstream}" \
    bash "${CONFIG_GEN_PATH}/${BUFSTREAM_CLOUD}-pg-setup.sh"
fi

if [[ "${BUFSTREAM_METADATA}" == "etcd" ]]; then
  echo "Installing ETCD..."
  helm \
    --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
    upgrade bufstream-etcd --install \
    oci://registry-1.docker.io/bitnamicharts/etcd \
    --namespace "${BUFSTREAM_NAMESPACE:-bufstream}" \
    --values ../config/etcd.yaml \
    --wait
fi


echo "Installing Bufstream..."
helm \
  --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  upgrade bufstream --install \
  oci://us-docker.pkg.dev/buf-images-1/buf/charts/bufstream \
  --version "${BUFSTREAM_VERSION}" \
  --namespace "${BUFSTREAM_NAMESPACE:-bufstream}" \
  --values "${CONFIG_GEN_PATH}/bufstream.yaml" \
  --wait
popd
