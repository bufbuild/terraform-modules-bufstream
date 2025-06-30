variable "project_id" {
  description = "The project id where the Spanner instance is provisioned"
  type        = string
}

variable "user_service_account" {
  description = "The service account to use for authentication for the Spanner database"
  type        = string
}

variable "instance_name" {
  description = "Name of the Spanner instance"
  type        = string
  default     = null
}

variable "spanner_config" {
  description = "The Spanner configuration to use"
  type        = string
}

variable "display_name" {
  description = "The display name for the Spanner instance."
  type        = string
  default     = "Bufstream Spanner Instance"
}

variable "num_nodes" {
  description = "The number of nodes allocated to the Spanner instance"
  type        = number
  default     = 1
}
