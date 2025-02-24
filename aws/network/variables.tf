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
  description = "Endpoint for s3 in your region."
  type        = string
  default     = null
}
