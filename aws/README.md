## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.99.1 |
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
| [aws_lb.bufstream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_security_group.bufstream-nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.bufstream_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.pg_secret_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description                                                                                                   | Type | Default | Required |
|------|---------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of bucket, must be globally unique                                                                       | `string` | n/a | yes |
| <a name="input_bufstream_k8s_namespace"></a> [bufstream\_k8s\_namespace](#input\_bufstream\_k8s\_namespace) | Namespace which bufstream will be installed.                                                                  | `string` | `"bufstream"` | no |
| <a name="input_bufstream_metadata"></a> [bufstream\_metadata](#input\_bufstream\_metadata) | DB type for Bufstream metadata                                                                                | `string` | n/a | yes |
| <a name="input_bufstream_service_account"></a> [bufstream\_service\_account](#input\_bufstream\_service\_account) | Service account name for bufstream.                                                                           | `string` | `"bufstream-service-account"` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Allow public access to cluster API endpoint.                                                                  | `string` | `true` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Create an Internet Gateway.                                                                                   | `bool` | `true` | no |
| <a name="input_create_nlb"></a> [create\_nlb](#input\_create\_nlb) | Create an NLB to associate with bufstream. This will make bufstream accessible outside the k8s cluster.       | `bool` | `true` | no |
| <a name="input_create_s3_endpoint"></a> [create\_s3\_endpoint](#input\_create\_s3\_endpoint) | Create s3 endpoint.                                                                                           | `bool` | `true` | no |
| <a name="input_create_subnets"></a> [create\_subnets](#input\_create\_subnets) | Create public and private subnets.                                                                            | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Create a VPC.                                                                                                 | `bool` | `true` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster.                                                                                      | `string` | `"bufstream-1"` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Version of the EKS cluster.                                                                                   | `string` | `"1.31"` | no |
| <a name="input_generate_config_files_path"></a> [generate\_config\_files\_path](#input\_generate\_config\_files\_path) | If present, generate config files for bufstream values, kubeconfig and the context name at the selected path. | `string` | `null` | no |
| <a name="input_postgres_db_name"></a> [postgres\_db\_name](#input\_postgres\_db\_name) | Name of the database for metadata                                                                             | `string` | `"bufstream"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | Postgres password for RDS instance                                                                            | `string` | `null` | no |
| <a name="input_postgres_username"></a> [postgres\_username](#input\_postgres\_username) | Postgres username for RDS instance                                                                            | `string` | `"postgres"` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Postgres version                                                                                              | `string` | `"17"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS profile for provider.                                                                                     | `string` | n/a | yes |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | Allocated storage for RDS                                                                                     | `number` | `20` | no |
| <a name="input_rds_identifier"></a> [rds\_identifier](#input\_rds\_identifier) | Identifier of the RDS instance                                                                                | `string` | `null` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | RDS instance class to use                                                                                     | `string` | `"db.c6gd.xlarge"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Port number for the RDS instance                                                                              | `number` | `5432` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy to.                                                                                          | `string` | `"us-west-2"` | no |
| <a name="input_s3_vpc_endpoint"></a> [s3\_vpc\_endpoint](#input\_s3\_vpc\_endpoint) | Optional endpoint for s3 in your region.                                                                      | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Optional IDs of the private subnets for the EKS cluster to use.                                               | `list(string)` | `[]` | no |
| <a name="input_use_pod_identity"></a> [use\_pod\_identity](#input\_use\_pod\_identity) | Use EKS pod identity (preferred) instead of IRSA.                                                             | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR range for the VPC, needs to be able to contain six contiguous /21 subnets. AWS recommends a /16 https://docs.aws.amazon.com/eks/latest/best-practices/custom-networking.html#_example_configuration         | `string` | `"10.64.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to use, required if `create_vpc` is `false`                                                         | `string` | `""` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC to create.                                                                                    | `string` | `"bufstream-vpc-1"` | no |

## Outputs

No outputs.
