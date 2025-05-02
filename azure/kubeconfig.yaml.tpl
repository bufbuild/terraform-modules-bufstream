apiVersion: v1
kind: Config
clusters:
  - cluster:
      certificate-authority-data: ${cluster_certificate}
      server: ${cluster_host}
    name: aks_${resource_group_name}_${cluster_name}
contexts:
  - context:
      cluster: aks_${resource_group_name}_${cluster_name}
      user: clusterAdmin_${resource_group_name}_${cluster_name}
    name: aks_${resource_group_name}_${cluster_name}
current-context: aks_${resource_group_name}_${cluster_name}
users:
  - name: clusterAdmin_${resource_group_name}_${cluster_name}
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1beta1
        args:
          - get-token
          - --login
          - azurecli
          - --server-id
          - 6dae42f8-4368-4678-94ff-3960e28e3630
        command: kubelogin
        env: null
        installHint: |
          kubelogin is not installed which is required to connect to AAD enabled cluster.
          To learn more, please go to https://aka.ms/aks/kubelogin
        provideClusterInfo: false
