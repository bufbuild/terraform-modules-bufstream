resource "random_string" "instance_name" {
  length  = 16
  special = false
  numeric = false
  upper   = false
}

locals {
  instance_name = var.instance_name != null ? var.instance_name : random_string.instance_name.result
}


resource "google_project_iam_member" "cloudsql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${var.service_account}"
}

resource "google_project_iam_member" "cloudsql_instance_user_role" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${var.service_account}"
}

resource "google_sql_database_instance" "bufpg" {
  name             = local.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier                        = var.cloudsql_tier
    disk_size                   = var.cloudsql_disk_size
    edition                     = var.cloudsql_edition
    availability_type           = var.cloudsql_availability_type
    deletion_protection_enabled = false


    ip_configuration {
      private_network = var.vpc_id
      ipv4_enabled    = false
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

resource "google_sql_database" "bufdb" {
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.bufpg.name
}
