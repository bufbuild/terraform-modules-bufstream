storage:
  use: azure
  azure:
    bucket: ${container_name}
    endpoint: https://${account_name}.blob.core.windows.net
bufstream:
  deployment:
    podLabels:
      azure.workload.identity/use: "true"
  serviceAccount:
    annotations:
      azure.workload.identity/client-id: ${bufstream_identity}
  %{~ if ip_address != "" ~}
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-ipv4: ${ip_address}
      service.beta.kubernetes.io/azure-load-balancer-internal: "true"
  %{~ endif ~}
metadata:
%{ if metadata == "etcd" ~}
  use: etcd
  etcd:
    addresses:
    - host: "bufstream-etcd.bufstream.svc.cluster.local"
      port: 2379
%{ endif ~}
%{ if metadata == "postgres" ~}
  use: postgres
  postgres:
    secretName: bufstream-postgres
%{ endif ~}
%{ if ip_address != "" ~}
kafka:
  publicAddress:
    host: ${ip_address}
    port: 9092
%{ endif ~}
