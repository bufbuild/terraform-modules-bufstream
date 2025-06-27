locals {
  compute_api_ref           = var.enable_apis ? google_project_service.apis["compute.googleapis.com"] : data.google_project_service.apis["compute.googleapis.com"]
  container_api_ref         = var.enable_apis ? google_project_service.apis["container.googleapis.com"] : data.google_project_service.apis["container.googleapis.com"]
  servicenetworking_api_ref = var.enable_apis ? google_project_service.apis["servicenetworking.googleapis.com"] : data.google_project_service.apis["servicenetworking.googleapis.com"]
  storage_api_ref           = var.enable_apis ? google_project_service.apis["storage.googleapis.com"] : data.google_project_service.apis["storage.googleapis.com"]
  sql_api_ref               = var.enable_apis ? (local.create_pg ? google_project_service.apis["sqladmin.googleapis.com"] : null) : (local.create_pg ? data.google_project_service.apis["sqladmin.googleapis.com"] : null)
  iam_api_ref               = var.enable_apis ? (local.create_pg ? google_project_service.apis["iam.googleapis.com"] : null) : (local.create_pg ? data.google_project_service.apis["iam.googleapis.com"] : null)
  spanner_api_ref           = var.enable_apis ? (local.create_spanner ? google_project_service.apis["spanner.googleapis.com"] : null) : (local.create_spanner ? data.google_project_service.apis["spanner.googleapis.com"] : null)



  create_pg      = var.bufstream_metadata == "postgres"
  create_spanner = var.bufstream_metadata == "spanner"

  base_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com",
  ]

  sql_apis = local.create_pg ? [
    "sqladmin.googleapis.com",
    "iam.googleapis.com"
  ] : []

  spanner_apis = local.create_spanner ? [
    "spanner.googleapis.com",
    "iam.googleapis.com"
  ] : []

  apis = toset(concat(local.base_apis, local.sql_apis, local.spanner_apis))

  spanner_config = var.spanner_config != null ? var.spanner_config : "regional-${var.region}"
}

resource "google_project_service" "apis" {
  for_each = var.enable_apis ? local.apis : []
  project  = var.project_id
  service  = each.value

  disable_dependent_services = true
  disable_on_destroy         = true
}

data "google_project_service" "apis" {
  for_each = var.enable_apis ? [] : local.apis
  project  = var.project_id
  service  = each.value
}

module "network" {
  source = "./network"

  project_id    = var.project_id
  vpc_create    = var.vpc_create
  vpc_name      = var.vpc_name
  subnet_create = var.subnet_create
  subnet_name   = var.subnet_name
  subnet_region = var.region
  subnet_cidr   = var.subnet_cidr

  pair_google_services = var.pair_google_services

  depends_on = [
    local.compute_api_ref,
  ]
}

module "kubernetes" {
  source = "./kubernetes"

  project_id = var.project_id
  region     = var.region

  cluster_create    = var.cluster_create
  cluster_name      = var.cluster_name
  machine_type      = var.machine_type
  ilb_firewall_cidr = var.ilb_firewall_cidr

  wif_create                        = var.wif_create
  wif_bufstream_k8s_namespace       = var.bufstream_k8s_namespace
  wif_bufstream_k8s_service_account = var.wif_bufstream_k8s_service_account

  service_account_create = var.service_account_create
  service_account_name   = var.service_account_name

  network = module.network.vpc_ref
  subnet  = module.network.subnet_ref

  depends_on = [
    local.compute_api_ref,
    local.container_api_ref,
    local.servicenetworking_api_ref,
  ]
}

module "storage" {
  source = "./storage"

  project_id = var.project_id
  region     = var.region

  bucket_create = var.bucket_create
  bucket_name   = var.bucket_name

  bucket_grant_permissions = var.bucket_grant_permissions

  create_custom_iam_role = var.create_custom_iam_role

  bufstream_service_account = module.kubernetes.bufstream_service_account

  depends_on = [
    local.storage_api_ref,
  ]
}

module "spanner" {
  count = local.create_spanner ? 1 : 0

  source = "./metadata/spanner"

  instance_name        = var.spanner_instance_name
  spanner_config       = local.spanner_config
  project_id           = var.project_id
  user_service_account = module.kubernetes.bufstream_service_account
  display_name         = var.spanner_display_name
  num_nodes            = var.spanner_num_nodes

  depends_on = [
    local.spanner_api_ref,
    local.iam_api_ref
  ]
}

module "postgres" {
  count = local.create_pg ? 1 : 0

  source = "./metadata/postgres"

  vpc_id                     = module.network.vpc_id
  region                     = var.region
  project_id                 = var.project_id
  instance_name              = var.instance_name
  database_version           = var.database_version
  database_name              = var.metadata_database_name
  cloudsql_tier              = var.cloudsql_tier
  cloudsql_disk_size         = var.cloudsql_disk_size
  cloudsql_availability_type = var.cloudsql_availability_type
  cloudsql_edition           = var.cloudsql_edition
  service_account            = module.kubernetes.bufstream_service_account

  depends_on = [
    local.sql_api_ref,
    local.iam_api_ref,
    module.network.private_service_network
  ]
}


locals {
  setup_pg      = var.generate_config_files_path != null && local.create_pg
  setup_spanner = var.generate_config_files_path != null && local.create_spanner
}

# We always create the IP address (instead of gating it conditionally on `create_internal_lb`,
# since if you ever flip the toggle back to destroy the internal LB, TF tries to destroy the IP
# address before modifying the bufstream release, which yields a failure since bufstream still
# uses the IP.
resource "google_compute_address" "ip" {
  project = var.project_id

  name = "bufstream"

  address_type = "INTERNAL"
  region       = var.region
  subnetwork   = module.network.subnet_ref
  purpose      = "SHARED_LOADBALANCER_VIP"
}

data "google_client_openid_userinfo" "user" {}

locals {
  sql_username = trimsuffix(module.kubernetes.bufstream_service_account, ".gserviceaccount.com")

  bufstream_values = templatefile("${path.module}/bufstream.yaml.tpl", {
    bucket_name                     = module.storage.bucket_ref
    bufstream_service_account_email = module.kubernetes.bufstream_service_account
    ip_address                      = var.create_internal_lb ? google_compute_address.ip.address : ""
    region                          = local.setup_pg ? var.region : ""
    metadata                        = var.bufstream_metadata
    sql_instance_name               = local.setup_pg ? module.postgres[0].cloudsql_instance_name : ""
    spanner_instance_id             = local.setup_spanner ? module.spanner[0].spanner_instance_name : ""
    db_name                         = local.setup_pg ? module.postgres[0].database_name : ""
    db_user                         = local.sql_username
    project_id                      = local.setup_pg || local.setup_spanner ? var.project_id : ""
  })

  kubeconfig = templatefile("${path.module}/kubeconfig.yaml.tpl", {
    project             = var.project_id
    region              = module.kubernetes.cluster_region
    cluster_name        = module.kubernetes.cluster_name
    cluster_host        = module.kubernetes.endpoint
    cluster_certificate = module.kubernetes.cert

    impersonate_account = strcontains(data.google_client_openid_userinfo.user.email, "gserviceaccount") ? data.google_client_openid_userinfo.user.email : null
  })

  pg_secret = local.setup_pg ? templatefile("${path.module}/pg-setup.sh.tpl", {
    project_id      = var.project_id,
    instance_name   = module.postgres[0].cloudsql_instance_name
    db_name         = module.postgres[0].database_name
    db_user         = local.sql_username
    service_account = module.postgres[0].cloudsql_service_account
    bucket          = module.storage.bucket_ref
  }) : null
}

resource "local_file" "pg_setup_script" {
  count    = local.setup_pg ? 1 : 0
  content  = local.pg_secret
  filename = "${var.generate_config_files_path}/gcp-pg-setup.sh"

  file_permission = "0700"
}

resource "local_file" "bufstream_values" {
  count    = var.generate_config_files_path != null ? 1 : 0
  content  = local.bufstream_values
  filename = "${var.generate_config_files_path}/bufstream.yaml"

  file_permission = "0600"
}

resource "local_file" "kubeconfig" {
  count    = var.generate_config_files_path != null ? 1 : 0
  content  = local.kubeconfig
  filename = "${var.generate_config_files_path}/kubeconfig.yaml"

  file_permission = "0600"
}
