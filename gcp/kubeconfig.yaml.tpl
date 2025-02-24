apiVersion: v1
kind: Config
users:
  - name: gke
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1beta1
        command: gke-gcloud-auth-plugin
        %{~ if impersonate_account != null ~}
        args:
          - --impersonate_service_account
          - ${impersonate_account}
        %{~ endif ~}
        installHint: Install gke-gcloud-auth-plugin for use with kubectl by following https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
        provideClusterInfo: true
clusters:
  - name: gke_${project}_${region}_${cluster_name}
    cluster:
      certificate-authority-data: ${cluster_certificate}
      server: https://${cluster_host}
      tls-server-name: kubernetes.default
contexts:
  - name: gke_${project}_${region}_${cluster_name}
    context:
      cluster: gke_${project}_${region}_${cluster_name}
      user: gke
