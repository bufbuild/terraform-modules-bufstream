locals {
  vpc_ref    = var.vpc_create ? google_compute_network.network[0].self_link : data.google_compute_network.network[0].self_link
  subnet_ref = var.subnet_create ? google_compute_subnetwork.subnetwork[0].self_link : data.google_compute_subnetwork.subnetwork[0].self_link
}

data "google_compute_network" "network" {
  count = var.vpc_create ? 0 : 1

  project = var.project_id
  name    = var.vpc_name
}

data "google_compute_subnetwork" "subnetwork" {
  count = var.subnet_create ? 0 : 1

  project = var.project_id
  name    = var.subnet_name
  region  = var.subnet_region
}

resource "google_compute_network" "network" {
  count = var.vpc_create ? 1 : 0

  project = var.project_id
  name    = var.vpc_name

  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = false
  enable_ula_internal_ipv6                  = false
  mtu                                       = 0
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  routing_mode                              = "GLOBAL"
}

# module.vpc.module.subnets.google_compute_subnetwork.subnetwork["us-central1/buf-gke-access-1-psc-consumer"]:
resource "google_compute_subnetwork" "subnetwork" {
  count = var.subnet_create ? 1 : 0

  project = var.project_id

  name                     = var.subnet_name
  region                   = var.subnet_region
  ip_cidr_range            = var.subnet_cidr
  network                  = local.vpc_ref
  private_ip_google_access = true
  purpose                  = "PRIVATE"
}

resource "google_compute_global_address" "google_managed_services" {
  count = var.pair_google_services ? 1 : 0

  name          = "google-managed-services-${var.vpc_name}"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16

  address = "192.168.0.0"
  network = local.vpc_ref
}

resource "google_service_networking_connection" "private_service_networking" {
  count = var.pair_google_services ? 1 : 0

  network = local.vpc_ref

  // This is all google services. A new peering connection would be needed for a marketplace service.
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.google_managed_services[0].name,
  ]
}
