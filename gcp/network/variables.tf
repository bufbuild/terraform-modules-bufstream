variable "project_id" {
  description = "Project to create the VPC in."
  type        = string
}

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

variable "subnet_region" {
  description = "Region to put the subnet in."
  type        = string
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
