storage:
  use: gcs
  gcs:
    bucket: ${bucket_name}
bufstream:
  serviceAccount:
    annotations:
      iam.gke.io/gcp-service-account: ${bufstream_service_account_email}
  %{~ if ip_address != "" ~}
  service:
    type: LoadBalancer
    loadBalancerIP: ${ip_address}
    annotations:
      networking.gke.io/load-balancer-type: "Internal"
  %{~ endif ~}
metadata:
%{ if metadata == "etcd" ~}
  use: etcd
  etcd:
    addresses:
    - host: "bufstream-etcd.bufstream.svc.cluster.local"
      port: 2379
%{ endif ~}
%{ if metadata == "spanner" ~}
  use: spanner
  spanner:
    projectId: ${project_id}
    instanceId: ${spanner_instance_id}
    database_name: bufstream
%{ endif ~}
%{ if metadata == "postgres" ~}
  use: postgres
  postgres:
    dsn: user=${db_user} database=${db_name}
    cloudsql:
      instance: ${project_id}:${region}:${sql_instance_name}
      iam: true
      privateIP: true
%{ endif ~}
%{ if ip_address != "" ~}
kafka:
  publicAddress:
    host: ${ip_address}
    port: 9092
%{ endif ~}
