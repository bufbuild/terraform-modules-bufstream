storage:
  use: gcs
  gcs:
    bucket: ${bucket_name}
bufstream:
  serviceAccount:
    annotations:
      iam.gke.io/gcp-service-account: ${bufstream_service_account_email}
  service:
    %{~ if ip_address != "" ~}
    type: LoadBalancer
    loadBalancerIP: ${ip_address}
    annotations:
      networking.gke.io/load-balancer-type: "Internal"
    %{~ endif ~}
metadata:
  use: etcd
  etcd:
    addresses:
    - host: "bufstream-etcd.bufstream.svc.cluster.local"
      port: 2379
%{ if ip_address != "" ~}
kafka:
  publicAddress:
    host: ${ip_address}
    port: 9092
%{ endif ~}
