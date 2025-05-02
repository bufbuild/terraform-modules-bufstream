#!/bin/bash

set -x
set -eo pipefail

if [[ "${BUFSTREAM_KEYFILE}" == "" ]] ; then
  echo "\$BUFSTREAM_KEYFILE must be defined pointing to the base64 encoding of the key to bufstream's chart private registry."
  exit 1
fi

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

BUFSTREAM_KEYFILE=$(realpath "${BUFSTREAM_KEYFILE}")
BUFSTREAM_TFVARS=$(realpath "${BUFSTREAM_TFVARS}")

CONFIG_GEN_PATH=$PWD/gen

echo "Authenticating Helm Chart..."
cat "${BUFSTREAM_KEYFILE}" | helm registry login -u _json_key_base64 --password-stdin \
  https://us-docker.pkg.dev/buf-images-1/bufstream

pushd "${BUFSTREAM_CLOUD}"

echo "Applying Terraform..."

TF_VAR_generate_config_files_path="${CONFIG_GEN_PATH}" \
  terraform apply \
  --var-file "${BUFSTREAM_TFVARS}" \
  --var "bufstream_k8s_namespace=${BUFSTREAM_NAMESPACE:-bufstream}"

# AWS does not come with a working storage class even on automode.
if [[ "${BUFSTREAM_CLOUD}" == "aws" ]] ; then
  echo "Creating AWS storage class..."
  kubectl \
      --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
      apply -f ../config/aws-storage-class.yaml
fi

echo "Create namespace..."
# Use dry run + apply to ignore existing namespace.
kubectl \
  --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  create namespace "${BUFSTREAM_NAMESPACE:-bufstream}" --dry-run=client -o yaml \
  | kubectl \
    --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
    apply -f -

echo "Installing ETCD..."
helm \
  --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  upgrade bufstream-etcd --install \
  oci://registry-1.docker.io/bitnamicharts/etcd \
  --namespace "${BUFSTREAM_NAMESPACE:-bufstream}" \
  --values ../config/etcd.yaml \
  --values "../config/etcd-${BUFSTREAM_CLOUD}.yaml" \
  --wait

echo "Installing Bufstream..."
helm \
  --kubeconfig "${CONFIG_GEN_PATH}/kubeconfig.yaml" \
  upgrade bufstream --install \
  oci://us-docker.pkg.dev/buf-images-1/bufstream/charts/bufstream \
  --version "${BUFSTREAM_VERSION}" \
  --namespace "${BUFSTREAM_NAMESPACE:-bufstream}" \
  --values "${CONFIG_GEN_PATH}/bufstream.yaml" \
  --wait
popd
