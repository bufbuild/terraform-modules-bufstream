variable "region" {
  description = "Region to deploy to."
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS profile for provider."
  type        = string
}

variable "bufstream_metadata" {
  description = "DB type for Bufstream metadata"
  type        = string

  validation {
    condition = contains(["postgres", "etcd", "aurora"], var.bufstream_metadata)

    error_message = "must be either 'postgres', 'aurora', or 'etcd'"
  }
}

# Networking vars

variable "create_vpc" {
  description = "Create a VPC."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of VPC to use, required if `create_vpc` is `false`"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC to create."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC, needs to be able to contain six contiguous /21 subnets. AWS suggests a /19 but most will recommend a /16 to avoid IP exhaustion. https://docs.aws.amazon.com/eks/latest/best-practices/ip-opt.html#_mitigate_ip_exhaustion"
  type        = string
  default     = "10.64.0.0/16"
}

variable "internal_only_nlb" {
  description = "toggle public accessibility of nlb on/off"
  type        = bool
  default     = true
}

variable "create_subnets" {
  description = "Create public and private subnets."
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Create an Internet Gateway."
  type        = bool
  default     = true
}

variable "create_s3_endpoint" {
  description = "Create s3 endpoint."
  type        = bool
  default     = true
}

variable "s3_vpc_endpoint" {
  description = "Optional endpoint for s3 in your region."
  type        = string
  default     = null
}

# EKS vars

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster."
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_public_access" {
  description = "Allow public access to cluster API endpoint."
  type        = string
  default     = true
}

variable "subnet_ids" {
  description = "Optional IDs of the private subnets for the EKS cluster to use."
  type        = list(string)
  default     = []
}

variable "use_pod_identity" {
  description = "Use EKS pod identity (preferred) instead of IRSA."
  type        = bool
  default     = true
}

variable "bufstream_k8s_namespace" {
  description = "Namespace which bufstream will be installed."
  type        = string
  default     = "bufstream"
}

variable "bufstream_service_account" {
  description = "Service account name for bufstream."
  type        = string
  default     = "bufstream-service-account"
}

variable "create_nlb" {
  description = "Create an NLB to associate with bufstream. This will make bufstream accessible outside the k8s cluster."
  type        = bool
  default     = true
}

# Storage vars

variable "bucket_name" {
  description = "Name of bucket, must be globally unique"
  type        = string
}

variable "generate_config_files_path" {
  description = "If present, generate config files for bufstream values, kubeconfig and the context name at the selected path."
  type        = string
  default     = null
}

# Metadata vars

variable "postgres_username" {
  description = "Postgres username for RDS instance"
  type        = string
  default     = "postgres"
}

variable "rds_identifier" {
  description = "Identifier of the RDS instance"
  type        = string
  default     = null
}

variable "rds_port" {
  description = "Port number for the RDS instance"
  type        = number
  default     = 5432
}

variable "rds_instance_class" {
  description = "RDS instance class to use"
  type        = string
  default     = "db.c6gd.xlarge"
}

variable "postgres_version" {
  description = "Postgres version"
  type        = string
  default     = "17"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}

variable "postgres_db_name" {
  description = "Name of the database for metadata"
  type        = string
  default     = "bufstream"
}

### aurora variables. not conendensed with prior to avoid breaking benchmark implementation

variable "aurora_identifier" {
  description = "Identifier of the Aurora instance"
  type        = string
  default     = null
}

variable "aurora_port" {
  description = "Port number for the Aurora instance"
  type        = number
  default     = 5432
}

variable "aurora_instance_class" {
  description = "Aurora instance class to use"
  type        = string
  default     = "db.r6gd.xlarge"
}

variable "availability_zone" {
  description = "Single AZ used for Aurora"
  type        = string
  default     = null
}

variable "cluster_instance_count" {
  description = "number of Aurora nodes to provision"
  type        = number
  default     = 2
}
