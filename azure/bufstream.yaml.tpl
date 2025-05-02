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
metadata:
  use: etcd
  etcd:
    addresses:
    - host: "bufstream-etcd.bufstream.svc.cluster.local"
      port: 2379
