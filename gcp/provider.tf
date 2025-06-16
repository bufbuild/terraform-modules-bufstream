terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.39.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
