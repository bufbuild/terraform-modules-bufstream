variable "cluster_name" {
  type    = string
  default = ""
}

variable "cluster_version" {
  type    = string
  default = "1.31"
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

variable "bufstream_namespace" {
  description = "Namespace which bufstream will be installed."
  type        = string
  default     = "bufstream"
}

variable "bufstream_service_account" {
  description = "Service account name for bufstream."
  type        = string
  default     = "bufstream-service-account"
}

variable "deployment_id" {
  description = "Unique ID suffix for object uniqueness"
  type        = string
}
