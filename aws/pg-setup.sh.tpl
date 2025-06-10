#!/bin/bash

PG_PASSWORD=$(
  aws secretsmanager get-secret-value \
    --profile "${aws_profile}" \
    --region "${region}" \
    --secret-id="${secret_arn}" \
    --query SecretString \
    --output text |
    jq '.password' -r |
    awk '{printf "%s", $0}' | jq -sRr @uri
)

manifest=$(
  cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: bufstream-postgres
  namespace:  "$NAMESPACE"
type: Opaque,
stringData:
  dsn: "${dsn}"
EOF
)

echo "$manifest" | kubectl apply -f - \
  --kubeconfig "$KUBECONFIG" \
  --namespace "$NAMESPACE"
