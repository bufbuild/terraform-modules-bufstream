variable "resource_group_name" {
  description = "Resource group name to create the aks cluster within."
  type        = string
}

variable "location" {
  description = "Where to deploy the resources. A region that supports availability zones is required."
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
  default     = "1.32"
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

variable "cluster_grant_admin" {
  description = "Grant admin role permission to the TF running actor. If cluster_admin_actor is set, use that, otherwise use the current caller."
  type        = bool
  default     = true
}

variable "cluster_grant_actor" {
  description = "If cluster_grant_admin and this are set, grant cluster admin role to user with this email."
  type        = string
  default     = null
}

variable "min_node_count" {
  description = "Minimum amount of nodes that autoscaler can place in the node pool."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum amount of nodes that autoscaler can place in the node pool."
  type        = number
  default     = 3
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
