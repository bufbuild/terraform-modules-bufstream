variable "resource_group_name" {
  description = "Resource group name to create the aks cluster within."
  type        = string
}

variable "location" {
  description = "Location of the AKS cluster."
  type        = string
}

variable "cluster_vm_size" {
  description = "Cluster VM size."
  type        = string
  default     = "Standard_D4as_v5"
}

variable "cluster_vnet_subnet_id" {
  description = "ID of subnet to use for nodes/cluster."
  type        = string
}

variable "cluster_pod_subnet_id" {
  description = "ID of subnet to use for pods."
  type        = string
}

variable "cluster_service_cidrs" {
  description = "Service CIDRs."
  type        = list(string)
  default     = ["10.192.8.0/23"]
}

variable "cluster_dns_service_ip" {
  description = "DNS Service IP."
  type        = string
  default     = "10.192.8.10"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use."
  type        = string
  default     = "1.31"
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

variable "wif_bufstream_k8s_namespace" {
  description = "Bufstream Kubernetes Service Account Namespace to use if enabling workload identity federation."
  type        = string
  default     = "bufstream"
}

variable "wif_bufstream_k8s_service_account" {
  description = "Bufstream Kubernetes Service Account Name to use if enabling workload identity federation."
  type        = string
  default     = "bufstream-service-account"
}
