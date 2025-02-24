variable "project_id" {
  description = "Project to create the VPC in."
  type        = string
}

variable "region" {
  description = "Region to put resources in."
  type        = string
}

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

variable "network" {
  description = "Name of VPC network to place cluster in case of creation."
  type        = string
}

variable "subnet" {
  description = "Name of VPC subnetnetwork to place cluster in case of creation."
  type        = string
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
