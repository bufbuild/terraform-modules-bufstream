#!/bin/bash

kubectl \
  --kubeconfig <(echo "$KUBECONFIG") \
  create namespace "$NAMESPACE" \
  --dry-run=client -o yaml |
  kubectl \
    --kubeconfig <(echo "$KUBECONFIG") \
    apply -f -

kubectl \
  --kubeconfig <(echo "$KUBECONFIG") \
  create secret \
  --namespace "$NAMESPACE" \
  generic bufstream-postgres \
  --from-literal=dsn="$DSN"
