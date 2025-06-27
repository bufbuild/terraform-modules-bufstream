resource "random_string" "instance_name" {
  length  = 16
  special = false
  numeric = false
  upper   = false
}

data "google_service_account" "bufstream_sa" {
  account_id = var.service_account
}

locals {
  instance_name = var.instance_name != null ? var.instance_name : random_string.instance_name.result
}

resource "google_project_iam_member" "spanner_database_admin" {
  project = var.project_id
  role    = "roles/spanner.databaseAdmin"
  member  = data.google_service_account.bufstream_sa.member
}

resource "google_project_iam_member" "spanner_database_user" {
  project = var.project_id
  role    = "roles/spanner.databaseUser"
  member  = data.google_service_account.bufstream_sa.member
}

resource "google_spanner_instance" "bufstream" {
  config       = var.spanner_config
  display_name = var.display_name
  name         = local.instance_name
  project      = var.project_id
  num_nodes    = var.num_nodes
}

