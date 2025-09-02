#!/bin/bash

### ###
function clean_up_gcp {
  BUCKET_DATA=$(gcloud storage buckets list --format json)
  BUCKET_NAME=$(echo $BUCKET_DATA | jq -r '.[].name')
  BUCKET_LCP=$(echo $BUCKET_DATA | jq -r '.[].lifecycle_config')
  if [[ "${BUCKET_LCP}" = "null" && -n "${BUCKET_NAME}" ]]; then
    echo '{"lifecycle": {"rule": [{"action": {"type": "Delete"},"condition": {"age": 0}}]}}' > ${CONFIG_GEN_PATH}/lifecycle.json
    gcloud storage buckets update gs://$BUCKET_NAME --lifecycle-file ${CONFIG_GEN_PATH}/lifecycle.json
    terraform state rm module.storage.google_storage_bucket.bufstream[0]
  fi
}

function clean_up_aws {
  BUCKET_NAME=$(terraform show -json | jq -r '.values.root_module.child_modules.[]?.resources.[]? | select (.type == "aws_s3_bucket") | .values.bucket')
  if [[ -n "${BUCKET_NAME}" ]]; then
    echo '{"Rules": [{"ID": "CleanUpExpirationPolicy", "Status": "Enabled", "Prefix": "*", "Expiration": {"Days": 1}}]}' > ${CONFIG_GEN_PATH}/lifecycle.json
    aws s3api put-bucket-lifecycle-configuration --bucket $BUCKET_NAME --lifecycle-configuration file://${CONFIG_GEN_PATH}/lifecycle.json > /dev/null #but what if it fails?
    terraform state rm module.storage.aws_s3_bucket.bufstream[0]
  fi
}

set -x
set -eo pipefail

if [[ "${BUFSTREAM_VERSION}" == "" ]] ; then
  echo "\$BUFSTREAM_VERSION must be defined to the desired bufstream version."
  exit 1
fi

if [[ "${BUFSTREAM_CLOUD}" == "" ]] ; then
  echo "\$BUFSTREAM_CLOUD must be defined to `gcp`, `aws` or `azure`."
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

echo "Initializing Terraform..."
  TF_VAR_generate_config_files_path="${CONFIG_GEN_PATH}" \
  TF_VAR_bufstream_metadata="${BUFSTREAM_METADATA}" \
  terraform init \
  --var-file "${BUFSTREAM_TFVARS}" \
  --var "bufstream_k8s_namespace=${BUFSTREAM_NAMESPACE:-bufstream}"

if [[ "$1" == "cleanup" ]] ; then
  read -p "cleanup will destroy all resources. are you sure? type y/yes to continue: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
  echo "Cleaning up Terraform..."
  case ${BUFSTREAM_CLOUD} in
    gcp)
      echo "gcp"
      clean_up_gcp
      ;;
    aws)
      echo "aws"
      clean_up_aws
      ;;
  esac
  TF_VAR_generate_config_files_path="${CONFIG_GEN_PATH}" \
  TF_VAR_bufstream_metadata="${BUFSTREAM_METADATA}" \
  terraform destroy \
  --var-file "${BUFSTREAM_TFVARS}" \
  --var "bufstream_k8s_namespace=${BUFSTREAM_NAMESPACE:-bufstream}" \
  -auto-approve
  if [[ "$BUFSTREAM_CLOUD" == "gcp" || "$BUFSTREAM_CLOUD" == "aws" ]]; then
    printf "warning - the bucket created by this script has to be deleted manually. it will begin emptying its contents soon. you can manually delete it at any time."
  fi
  exit 0
fi



echo "Applying Terraform..."
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



