

data "google_service_account" "bufstream_sa" {
  account_id = var.user_service_account
}

resource "google_spanner_instance_iam_member" "spanner_database_admin" {
  instance = google_spanner_instance.bufstream.name
  project  = var.project_id
  role     = "roles/spanner.databaseAdmin"
  member   = data.google_service_account.bufstream_sa.member
}

resource "google_spanner_instance_iam_member" "spanner_database_user" {
  instance = google_spanner_instance.bufstream.name
  project  = var.project_id
  role     = "roles/spanner.databaseUser"
  member   = data.google_service_account.bufstream_sa.member
}

resource "google_spanner_instance" "bufstream" {
  config       = var.spanner_config
  display_name = var.display_name
  name         = var.instance_name
  project      = var.project_id
  num_nodes    = var.num_nodes
}
