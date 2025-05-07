## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.27.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | ./kubernetes | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./network | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./storage | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_provider_registration.registrations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration) | resource |
| [local_file.bufstream_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bufstream_identity_create"></a> [bufstream\_identity\_create](#input\_bufstream\_identity\_create) | Whether to create a new Azure bufstream identity. | `bool` | `true` | no |
| <a name="input_bufstream_identity_name"></a> [bufstream\_identity\_name](#input\_bufstream\_identity\_name) | Name of Azure bufstream identity. | `string` | `"bufstream"` | no |
| <a name="input_bufstream_k8s_namespace"></a> [bufstream\_k8s\_namespace](#input\_bufstream\_k8s\_namespace) | Bufstream Kubernetes Service Account Namespace to use if enabling workload identity federation. | `string` | `"bufstream"` | no |
| <a name="input_cluster_create"></a> [cluster\_create](#input\_cluster\_create) | Whether to create a new AKS cluster. | `bool` | `true` | no |
| <a name="input_cluster_dns_service_ip"></a> [cluster\_dns\_service\_ip](#input\_cluster\_dns\_service\_ip) | DNS Service IP. Must be within services\_subnet\_cidr. | `string` | `"10.192.4.10"` | no |
| <a name="input_cluster_grant_admin_to_caller"></a> [cluster\_grant\_admin\_to\_caller](#input\_cluster\_grant\_admin\_to\_caller) | Grant admin role permission to the TF running actor. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of AKS cluster to create or use. | `string` | `"bufstream"` | no |
| <a name="input_cluster_subnet_cidr"></a> [cluster\_subnet\_cidr](#input\_cluster\_subnet\_cidr) | CIDR of cluster subnet in the VPC. | `string` | `"10.192.0.0/23"` | no |
| <a name="input_cluster_subnet_create"></a> [cluster\_subnet\_create](#input\_cluster\_subnet\_create) | Whether to create a cluster subnet in the VPC. | `bool` | `true` | no |
| <a name="input_cluster_subnet_name"></a> [cluster\_subnet\_name](#input\_cluster\_subnet\_name) | Name of cluster subnet in the VPC. | `string` | `"bufstream-cluster"` | no |
| <a name="input_cluster_vm_size"></a> [cluster\_vm\_size](#input\_cluster\_vm\_size) | Cluster VM size. | `string` | `"Standard_D4as_v5"` | no |
| <a name="input_generate_config_files_path"></a> [generate\_config\_files\_path](#input\_generate\_config\_files\_path) | If present, generate config files for bufstream values, kubeconfig and the context name at the selected path. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use. | `string` | `"1.32"` | no |
| <a name="input_location"></a> [location](#input\_location) | Where to deploy the resources. A region with zones is required. | `string` | `"centralus"` | no |
| <a name="input_pods_subnet_cidr"></a> [pods\_subnet\_cidr](#input\_pods\_subnet\_cidr) | CIDR of the pods subnet in the VPC. | `string` | `"10.192.2.0/23"` | no |
| <a name="input_pods_subnet_create"></a> [pods\_subnet\_create](#input\_pods\_subnet\_create) | Whether to create a pods subnet in the VPC. | `bool` | `true` | no |
| <a name="input_pods_subnet_name"></a> [pods\_subnet\_name](#input\_pods\_subnet\_name) | Name of pods subnet in the VPC. | `string` | `"bufstream-pods"` | no |
| <a name="input_resource_group_create"></a> [resource\_group\_create](#input\_resource\_group\_create) | Whether to create a new resource group. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of new resource group to create or use. | `string` | `"bufstream"` | no |
| <a name="input_services_subnet_cidr"></a> [services\_subnet\_cidr](#input\_services\_subnet\_cidr) | Services CIDR. It is auto-created with the cluster if cluster\_create is true. | `string` | `"10.192.4.0/23"` | no |
| <a name="input_storage_account_create"></a> [storage\_account\_create](#input\_storage\_account\_create) | Whether to create a new storage account. | `string` | `true` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account. | `string` | `"bufstream"` | no |
| <a name="input_storage_container_create"></a> [storage\_container\_create](#input\_storage\_container\_create) | Whether to create a new storage container. | `string` | `true` | no |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Name of the storage container. | `string` | `"bufstream"` | no |
| <a name="input_storage_grant_permissions"></a> [storage\_grant\_permissions](#input\_storage\_grant\_permissions) | Whether to grant necessary permissions on the storage account for the bufstream identity. | `string` | `true` | no |
| <a name="input_storage_kind"></a> [storage\_kind](#input\_storage\_kind) | Storage account kind. | `string` | `"StorageV2"` | no |
| <a name="input_storage_large_file_share_enabled"></a> [storage\_large\_file\_share\_enabled](#input\_storage\_large\_file\_share\_enabled) | Storage Large file share enabled. | `bool` | `false` | no |
| <a name="input_storage_replication_type"></a> [storage\_replication\_type](#input\_storage\_replication\_type) | Storage account replication type. | `string` | `"RAGRS"` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | Storage account tier. | `string` | `"Standard"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of new VPC to create or use. | `string` | `"10.192.0.0/16"` | no |
| <a name="input_vpc_create"></a> [vpc\_create](#input\_vpc\_create) | Whether to create a new VPC. | `bool` | `true` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of new VPC to create or use. | `string` | `"bufstream"` | no |
| <a name="input_wif_bufstream_k8s_service_account"></a> [wif\_bufstream\_k8s\_service\_account](#input\_wif\_bufstream\_k8s\_service\_account) | Bufstream Kubernetes Service Account Name to use if enabling workload identity federation. | `string` | `"bufstream-service-account"` | no |
| <a name="input_wif_create"></a> [wif\_create](#input\_wif\_create) | Whether to enable workload identity federation. | `string` | `true` | no |

## Outputs

No outputs.
