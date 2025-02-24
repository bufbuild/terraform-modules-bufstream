variable "region" {
  description = "Region to deploy to."
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS profile for provider."
  type        = string
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
  default     = "bufstream-vpc-1"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC, needs to be able to contain six contiguous /21 subnets."
  type        = string
  default     = "10.64.0.0/16"
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
  default     = "bufstream-1"
}

variable "eks_cluster_version" {
  description = "Version of the EKS cluster."
  type        = string
  default     = "1.31"
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
