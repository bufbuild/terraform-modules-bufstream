variable "resource_group_create" {
  description = "Whether to create a new resource group."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of new resource group to create or use."
  type        = string
  default     = "bufstream"
}

variable "location" {
  description = "Where to deploy the resources."
  type        = string
  default     = "centralus"
}

# Network
variable "vpc_create" {
  description = "Whether to create a new VPC."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name of new VPC to create or use."
  type        = string
  default     = "bufstream"
}

variable "vpc_cidr" {
  description = "CIDR of new VPC to create or use."
  type        = string
  default     = "10.192.0.0/16"
}

variable "cluster_subnet_create" {
  description = "Whether to create a cluster subnet in the VPC."
  type        = bool
  default     = true
}

variable "cluster_subnet_name" {
  description = "Name of cluster subnet in the VPC."
  type        = string
  default     = "bufstream-cluster"
}

variable "cluster_subnet_cidr" {
  description = "CIDR of cluster subnet in the VPC."
  type        = string
  default     = "10.192.0.0/23"
}

variable "pods_subnet_create" {
  description = "Whether to create a pods subnet in the VPC."
  type        = bool
  default     = true
}

variable "pods_subnet_name" {
  description = "Name of pods subnet in the VPC."
  type        = string
  default     = "bufstream-pods"
}

variable "pods_subnet_cidr" {
  description = "CIDR of the pods subnet in the VPC."
  type        = string
  default     = "10.192.2.0/23"
}

variable "services_subnet_cidr" {
  description = "Services CIDR. It is auto-created with the cluster if cluster_create is true."
  type        = string
  default     = "10.192.4.0/23"
}

# Kubernetes Cluster

variable "kubernetes_version" {
  description = "Kubernetes version to use."
  type        = string
  default     = "1.31"
}

variable "cluster_vm_size" {
  description = "Cluster VM size."
  type        = string
  default     = "Standard_D4as_v5"
}

variable "cluster_dns_service_ip" {
  description = "DNS Service IP. Must be within services_subnet_cidr."
  type        = string
  default     = "10.192.4.10"
}

variable "cluster_create" {
  description = "Whether to create a new AKS cluster."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of AKS cluster to create or use."
  type        = string
  default     = "bufstream"
}

variable "cluster_grant_admin_to_caller" {
  description = "Grant admin role permission to the TF running actor."
  type        = bool
  default     = true
}

variable "bufstream_identity_create" {
  description = "Whether to create a new Azure bufstream identity."
  type        = bool
  default     = true
}

variable "bufstream_identity_name" {
  description = "Name of Azure bufstream identity."
  type        = string
  default     = "bufstream"
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

# Storage

variable "storage_account_create" {
  description = "Whether to create a new storage account."
  type        = string
  default     = true
}

variable "storage_account_name" {
  description = "Name of the storage account."
  type        = string
  default     = "bufstream"
}

variable "storage_container_create" {
  description = "Whether to create a new storage container."
  type        = string
  default     = true
}

variable "storage_container_name" {
  description = "Name of the storage container."
  type        = string
  default     = "bufstream"
}

variable "storage_kind" {
  description = "Storage account kind."
  type        = string
  default     = "StorageV2"
}

variable "storage_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type."
  type        = string
  default     = "LRS"
}

variable "storage_large_file_share_enabled" {
  description = "Storage Large file share enabled."
  type        = bool
  default     = false
}

variable "storage_grant_permissions" {
  description = "Whether to grant necessary permissions on the storage account for the bufstream identity."
  type        = string
  default     = true
}

# Config Gen

variable "generate_config_files_path" {
  description = "If present, generate config files for bufstream values, kubeconfig and the context name at the selected path."
  type        = string
  default     = null
}
