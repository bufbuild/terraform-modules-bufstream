#!/bin/bash

# Set up the bufstream user with appropriate privileges.
tmpdir=$(mktemp -d)
sqlfile="db-setup.sql"
sqlfilepath="$tmpdir/$sqlfile"
cat <<EOF >"$sqlfilepath"
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO "${db_user}";
GRANT ALL ON SCHEMA public TO "${db_user}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${db_user}";
EOF

# Temporarily give sql instance access to bucket
gcloud storage buckets add-iam-policy-binding "gs://${bucket}" \
  --member="serviceAccount:${service_account}" \
  --role="roles/storage.objectViewer"

gcloud sql users create ${db_user} \
  --project=${project_id} \
  --instance=${instance_name} \
  --type=cloud_iam_service_account

gcloud storage cp \
  "$sqlfilepath" \
  "gs://${bucket}/$sqlfile" \
  --quiet

gcloud sql import sql \
  --project=${project_id} \
  "${instance_name}" \
  "gs://${bucket}/$sqlfile" \
  --database ${db_name} \
  --quiet

gcloud storage buckets remove-iam-policy-binding "gs://${bucket}" \
  --member="serviceAccount:${service_account}" \
  --role="roles/storage.objectViewer"

gcloud storage rm "gs://${bucket}/$sqlfile"
rm -rf "$tmpdir"
