storage:
  use: s3
  s3:
    bucket: ${bucket_name}
    region: ${region}
bufstream:
%{ if hostname != "" ~}
  service:
      type: LoadBalancer
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "external"
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "${lb_scheme}"
%{ endif ~}
%{ if role_arn != "" ~}
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${role_arn}
%{ endif ~}
%{ if hostname != "" ~}
kafka:
  publicAddress:
    host: ${hostname}
    port: 9092
%{ endif ~}
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
