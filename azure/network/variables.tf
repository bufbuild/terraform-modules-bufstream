variable "vpc_create" {
  description = "Whether to create a new VPC in GCP."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name of new VPC to create or use."
  type        = string
  default     = "bufstream"
}

variable "resource_group_name" {
  description = "Name of new Resource Group to create."
  type        = string
}

variable "location" {
  description = "Location where to create resources in."
  type        = string
}

variable "address_space" {
  description = "Virtual network address space"
  type        = list(string)
}

variable "cluster_subnet_create" {
  description = "Wether to create a cluster subnet in the VPC."
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
  description = "Wether to create a pods subnet in the VPC."
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
