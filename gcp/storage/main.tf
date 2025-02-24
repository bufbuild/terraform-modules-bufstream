locals {
  bucket_ref = var.bucket_create ? google_storage_bucket.bufstream[0].name : data.google_storage_bucket.bufstream[0].name
}

data "google_storage_bucket" "bufstream" {
  count = var.bucket_create ? 0 : 1

  project = var.project_id

  name = var.bucket_name
}

resource "google_storage_bucket" "bufstream" {
  count = var.bucket_create ? 1 : 0

  project = var.project_id

  name          = var.bucket_name
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

resource "google_project_iam_custom_role" "bufstream_iam_role" {
  count = var.create_custom_iam_role ? 1 : 0

  project     = var.project_id
  role_id     = "bufstream.gcsAdmin"
  title       = "Bufstream GCS Admin"
  description = "Provides Minimum GCS Permissions needed for Bufstream"

  permissions = [
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.delete",
    "storage.objects.list",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.create",
    "storage.multipartUploads.list",
    "storage.multipartUploads.listParts",
  ]
}

resource "google_storage_bucket_iam_member" "bucket_policy" {
  count = var.bucket_grant_permissions ? 1 : 0

  bucket = local.bucket_ref
  role   = var.create_custom_iam_role ? google_project_iam_custom_role.bufstream_iam_role[0].name : "roles/storage.objectAdmin"
  member = "serviceAccount:${var.bufstream_service_account}"
}
