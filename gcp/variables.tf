variable "project_id" {
  description = "Project to create the VPC in."
  type        = string
}

variable "region" {
  description = "Region where to create resources in."
  type        = string
}

variable "enable_apis" {
  description = "Enable required googleapis."
  type        = bool
  default     = true
}

# Networking Variables

variable "vpc_create" {
  description = "Whether to create a new VPC in GCP."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name of new VPC to create or use."
  type        = string
  default     = "bufstream-1"
}

variable "subnet_create" {
  description = "Whether to create a new subnet in the VPC referenced above."
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name of new subnet to create or use."
  type        = string
  default     = "bufstream-subnet-1"
}

variable "subnet_cidr" {
  description = "CIDR of new subnet to create in case of creation."
  type        = string
  default     = "10.20.0.0/23"
}

variable "pair_google_services" {
  description = "Whether to create the VPC routes for google managed services."
  type        = string
  default     = true
}

# Kubernetes

variable "cluster_create" {
  description = "Whether to create a new GKE cluster."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of GKE Cluster to create or use."
  type        = string
  default     = "bufstream-1"
}

variable "machine_type" {
  description = "Machine type to use for node pools in case of creation."
  type        = string
  default     = "e2-standard-8"
}

variable "ilb_firewall_cidr" {
  description = "CIDR to create a firewall to allow ILB access to the cluster."
  type        = string
  default     = null
}

variable "wif_create" {
  description = "Whether to enable workload identity federation."
  type        = string
  default     = true
}

variable "bufstream_k8s_namespace" {
  description = "Bufstream Kubernetes Service Account Namespace to use if enabling workload identity federation."
  type        = string
  default     = "bufstream"
}

variable "wif_bufstream_k8s_service_account" {
  description = "Bufstream Kubernetes Service Account Name to use if enabling workload identity federation."
  type        = string
  default     = "bufstream-service-account"
}

variable "service_account_create" {
  description = "Whether to create a GCP bufstream service account or use an existing one."
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Name of service account to create or use."
  type        = string
  default     = "bufstream"
}

variable "create_internal_lb" {
  description = "Create VPC-internal load balancer without SSL."
  type        = bool
  default     = false
}

# Storage

variable "bucket_create" {
  description = "Whether to create a new GCS bucket."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Project to create the VPC in."
  type        = string
}

variable "bucket_grant_permissions" {
  description = "Whether to grant necessary permissions on the bucket for the bufstream service account."
  type        = string
  default     = true
}

variable "create_custom_iam_role" {
  description = "Whether to create and use a custom GCP IAM role with minimal GCS permissions."
  type        = bool
  default     = true
}

variable "generate_config_files_path" {
  description = "If present, generate config files for bufstream values, kubeconfig and the context name at the selected path."
  type        = string
  default     = null
}
