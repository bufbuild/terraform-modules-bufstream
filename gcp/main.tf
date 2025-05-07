locals {
  compute_api_ref           = var.enable_apis ? google_project_service.apis["compute.googleapis.com"] : data.google_project_service.apis["compute.googleapis.com"]
  container_api_ref         = var.enable_apis ? google_project_service.apis["container.googleapis.com"] : data.google_project_service.apis["container.googleapis.com"]
  servicenetworking_api_ref = var.enable_apis ? google_project_service.apis["servicenetworking.googleapis.com"] : data.google_project_service.apis["servicenetworking.googleapis.com"]
  storage_api_ref           = var.enable_apis ? google_project_service.apis["storage.googleapis.com"] : data.google_project_service.apis["storage.googleapis.com"]
}

resource "google_project_service" "apis" {
  for_each = var.enable_apis ? toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com",
  ]) : []

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = true
}

data "google_project_service" "apis" {
  for_each = var.enable_apis ? [] : toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage.googleapis.com",
  ])

  project = var.project_id
  service = each.value
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
  bufstream_values = templatefile("${path.module}/bufstream.yaml.tpl", {
    bucket_name                     = module.storage.bucket_ref
    bufstream_service_account_email = module.kubernetes.bufstream_service_account
    ip_address                      = var.create_internal_lb ? google_compute_address.ip.address : ""
  })

  kubeconfig = templatefile("${path.module}/kubeconfig.yaml.tpl", {
    project             = var.project_id
    region              = module.kubernetes.cluster_region
    cluster_name        = module.kubernetes.cluster_name
    cluster_host        = module.kubernetes.endpoint
    cluster_certificate = module.kubernetes.cert

    impersonate_account = strcontains(data.google_client_openid_userinfo.user.email, "gserviceaccount") ? data.google_client_openid_userinfo.user.email : null
  })
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
