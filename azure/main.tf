resource "random_string" "rg_id" {
  length  = 10
  special = false
  numeric = false
  upper   = false
}

locals {
  rg_name = var.resource_group_create ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
}

resource "azurerm_resource_group" "rg" {
  count = var.resource_group_create ? 1 : 0

  name     = "var.resource_group_name-${local.rg_id}"
  location = var.location
}

data "azurerm_resource_group" "rg" {
  count = var.resource_group_create ? 0 : 1

  name = var.resource_group_name
}

locals {
  pg_create = var.bufstream_metadata == "postgres"
}

module "metadata" {
  count  = local.pg_create ? 1 : 0
  source = "./metadata/postgres"

  instance_name     = var.instance_name
  pg_version        = var.pg_version
  pg_admin_username = var.pg_admin_username
  pg_sku_name       = var.pg_sku_name
  pg_storage_mb     = var.pg_storage_mb
  pg_subnet_cidr    = var.pg_subnet_cidr
  resource_group    = local.rg_name
  location          = var.location
  vpc_name          = module.network.vpc_name

  depends_on = [module.network]
}

module "network" {
  source = "./network"

  vpc_create          = var.vpc_create
  vpc_name            = var.vpc_name
  resource_group_name = local.rg_name
  location            = var.location

  address_space = [var.vpc_cidr]

  cluster_subnet_create = var.cluster_subnet_create
  cluster_subnet_name   = var.cluster_subnet_name
  cluster_subnet_cidr   = var.cluster_subnet_cidr
  pods_subnet_create    = var.pods_subnet_create
  pods_subnet_name      = var.pods_subnet_name
  pods_subnet_cidr      = var.pods_subnet_cidr
}

module "kubernetes" {
  source = "./kubernetes"

  resource_group_name = local.rg_name
  location            = var.location

  kubernetes_version = var.kubernetes_version

  cluster_create = var.cluster_create
  cluster_name   = var.cluster_name

  cluster_grant_admin = var.cluster_grant_admin

  cluster_vm_size        = var.cluster_vm_size
  cluster_service_cidrs  = [var.services_subnet_cidr]
  cluster_dns_service_ip = var.cluster_dns_service_ip
  cluster_vnet_subnet_id = module.network.cluster_subnet.id
  cluster_pod_subnet_id  = module.network.pods_subnet.id

  bufstream_identity_create = var.bufstream_identity_create
  bufstream_identity_name   = var.bufstream_identity_name

  wif_create                        = var.wif_create
  wif_bufstream_k8s_namespace       = var.bufstream_k8s_namespace
  wif_bufstream_k8s_service_account = var.wif_bufstream_k8s_service_account
}

module "storage" {
  source = "./storage"

  storage_account_create   = var.storage_account_create
  storage_container_create = var.storage_container_create

  storage_account_name   = var.storage_account_name
  storage_container_name = var.storage_container_name
  resource_group_name    = local.rg_name
  location               = var.location

  storage_kind             = var.storage_kind
  storage_tier             = var.storage_tier
  storage_replication_type = var.storage_replication_type

  storage_large_file_share_enabled = var.storage_large_file_share_enabled

  bufstream_identity = module.kubernetes.bufstream_identity.principal_id
}

locals {
  bufstream_values = templatefile("${path.module}/bufstream.yaml.tpl", {
    account_name       = module.storage.storage_account_name
    container_name     = module.storage.storage_container_name
    bufstream_identity = module.kubernetes.bufstream_identity.client_id
    ip_address         = var.internal_lb_address
    metadata           = var.bufstream_metadata
  })

  kubeconfig = templatefile("${path.module}/kubeconfig.yaml.tpl", {
    resource_group_name = local.rg_name
    cluster_name        = module.kubernetes.cluster_name
    cluster_host        = module.kubernetes.endpoint
    cluster_certificate = module.kubernetes.cert

    admin_user     = module.kubernetes.admin_user
    admin_password = module.kubernetes.admin_password
    client_cert    = module.kubernetes.client_cert
    client_key     = module.kubernetes.client_key
  })

  pgsecret = local.pg_create ? templatefile("${path.module}/pg-setup.sh.tpl", {
    server_name    = module.metadata[0].server_name
    resource_group = local.rg_name
    db_username    = module.metadata[0].db_username
    pg_endpoint    = module.metadata[0].pg_endpoint
    db_name        = module.metadata[0].db_name
  }) : null
}

resource "local_file" "pg_setup_script" {
  count           = var.generate_config_files_path != null && local.pg_create ? 1 : 0
  content         = local.pgsecret
  filename        = "${var.generate_config_files_path}/azure-pg-setup.sh"
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
