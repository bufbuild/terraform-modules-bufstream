#!/bin/bash

PG_PASSWORD=$(tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><~' < /dev/urandom | head -c 64)

az postgres flexible-server update \
  --name "${server_name}" \
  --resource-group "${resource_group}" \
  --admin-password "$PG_PASSWORD"

pw="$(echo -n $PG_PASSWORD | jq -sRr @uri)" 
DSN="postgresql://${db_username}:$${pw}@${pg_endpoint}/${db_name}?sslmode=require"

manifest=$(
  cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: bufstream-postgres
  namespace:  "$NAMESPACE"
type: Opaque,
stringData:
  dsn: "$DSN"
EOF
)

echo "$manifest" | kubectl apply -f - \
  --kubeconfig "$KUBECONFIG" \
  --namespace "$NAMESPACE"
