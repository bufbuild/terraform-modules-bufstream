## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.39.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.39.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | ./kubernetes | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./network | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ./metadata/postgres | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./storage | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [local_file.bufstream_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.pg_setup_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [google_client_openid_userinfo.user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_project_service.apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_create"></a> [bucket\_create](#input\_bucket\_create) | Whether to create a new GCS bucket. | `bool` | `true` | no |
| <a name="input_bucket_grant_permissions"></a> [bucket\_grant\_permissions](#input\_bucket\_grant\_permissions) | Whether to grant necessary permissions on the bucket for the bufstream service account. | `string` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Project to create the VPC in. | `string` | n/a | yes |
| <a name="input_bufstream_k8s_namespace"></a> [bufstream\_k8s\_namespace](#input\_bufstream\_k8s\_namespace) | Bufstream Kubernetes Service Account Namespace to use if enabling workload identity federation. | `string` | `"bufstream"` | no |
| <a name="input_bufstream_metadata"></a> [bufstream\_metadata](#input\_bufstream\_metadata) | DB type for Bufstream metadata | `string` | n/a | yes |
| <a name="input_cloudsql_availability_type"></a> [cloudsql\_availability\_type](#input\_cloudsql\_availability\_type) | Availability type of the database instance - must be 'REGIONAL' or 'ZONAL' | `string` | `"REGIONAL"` | no |
| <a name="input_cloudsql_disk_size"></a> [cloudsql\_disk\_size](#input\_cloudsql\_disk\_size) | Disk size in GB for the database instance | `number` | `100` | no |
| <a name="input_cloudsql_edition"></a> [cloudsql\_edition](#input\_cloudsql\_edition) | The edition of the database instance - must be 'ENTERPRISE' or 'ENTERPRISE\_PLUS' | `string` | `"ENTERPRISE"` | no |
| <a name="input_cloudsql_tier"></a> [cloudsql\_tier](#input\_cloudsql\_tier) | Tier for the database instance | `string` | `"db-custom-4-8192"` | no |
| <a name="input_cluster_create"></a> [cluster\_create](#input\_cluster\_create) | Whether to create a new GKE cluster. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of GKE Cluster to create or use. | `string` | `"bufstream-1"` | no |
| <a name="input_create_custom_iam_role"></a> [create\_custom\_iam\_role](#input\_create\_custom\_iam\_role) | Whether to create and use a custom GCP IAM role with minimal GCS permissions. | `bool` | `true` | no |
| <a name="input_create_internal_lb"></a> [create\_internal\_lb](#input\_create\_internal\_lb) | Create VPC-internal load balancer without SSL. | `bool` | `false` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | The database version for the CloudSQL instance - must be POSTGRES | `string` | `"POSTGRES_17"` | no |
| <a name="input_enable_apis"></a> [enable\_apis](#input\_enable\_apis) | Enable required googleapis. | `bool` | `true` | no |
| <a name="input_generate_config_files_path"></a> [generate\_config\_files\_path](#input\_generate\_config\_files\_path) | If present, generate config files for bufstream values, kubeconfig and the context name at the selected path. | `string` | `null` | no |
| <a name="input_ilb_firewall_cidr"></a> [ilb\_firewall\_cidr](#input\_ilb\_firewall\_cidr) | CIDR to create a firewall to allow ILB access to the cluster. | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the CloudSQL instance | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type to use for node pools in case of creation. | `string` | `"e2-standard-8"` | no |
| <a name="input_metadata_database_name"></a> [metadata\_database\_name](#input\_metadata\_database\_name) | The database name to use for Bufstream | `string` | `"bufstream"` | no |
| <a name="input_pair_google_services"></a> [pair\_google\_services](#input\_pair\_google\_services) | Whether to create the VPC routes for google managed services. | `string` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project to create the VPC in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where to create resources in. | `string` | n/a | yes |
| <a name="input_service_account_create"></a> [service\_account\_create](#input\_service\_account\_create) | Whether to create a GCP bufstream service account or use an existing one. | `bool` | `true` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of service account to create or use. | `string` | `"bufstream"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of new subnet to create in case of creation. | `string` | `"10.20.0.0/23"` | no |
| <a name="input_subnet_create"></a> [subnet\_create](#input\_subnet\_create) | Whether to create a new subnet in the VPC referenced above. | `bool` | `true` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of new subnet to create or use. | `string` | `"bufstream-subnet-1"` | no |
| <a name="input_vpc_create"></a> [vpc\_create](#input\_vpc\_create) | Whether to create a new VPC in GCP. | `bool` | `true` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of new VPC to create or use. | `string` | `"bufstream-1"` | no |
| <a name="input_wif_bufstream_k8s_service_account"></a> [wif\_bufstream\_k8s\_service\_account](#input\_wif\_bufstream\_k8s\_service\_account) | Bufstream Kubernetes Service Account Name to use if enabling workload identity federation. | `string` | `"bufstream-service-account"` | no |
| <a name="input_wif_create"></a> [wif\_create](#input\_wif\_create) | Whether to enable workload identity federation. | `string` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bufstream_values"></a> [bufstream\_values](#output\_bufstream\_values) | Values file for bufstream. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig file to access the cluster. |
