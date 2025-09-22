locals {
  cluster_ref        = var.cluster_create ? google_container_cluster.bufstream[0].self_link : data.google_container_cluster.bufstream[0].self_link
  cluster_name       = var.cluster_create ? google_container_cluster.bufstream[0].name : data.google_container_cluster.bufstream[0].name
  cluster_region     = var.cluster_create ? google_container_cluster.bufstream[0].location : data.google_container_cluster.bufstream[0].location
  cluster_endpoint   = var.cluster_create ? google_container_cluster.bufstream[0].endpoint : data.google_container_cluster.bufstream[0].endpoint
  cluster_cert       = var.cluster_create ? google_container_cluster.bufstream[0].master_auth[0].cluster_ca_certificate : data.google_container_cluster.bufstream[0].master_auth[0].cluster_ca_certificate
  bufstream_sa_ref   = var.service_account_create ? google_service_account.bufstream[0].id : data.google_service_account.bufstream[0].id
  bufstream_sa_email = var.service_account_create ? google_service_account.bufstream[0].email : data.google_service_account.bufstream[0].email
}

data "google_container_cluster" "bufstream" {
  count = var.cluster_create ? 0 : 1

  project = var.project_id

  name     = var.cluster_name
  location = var.region
}

resource "google_service_account" "bufstream_cluster" {
  count = var.cluster_create ? 1 : 0

  project      = var.project_id
  account_id   = "gke-${var.cluster_name}"
  display_name = "Bufstream Cluster Service Account"
}

resource "google_container_cluster" "bufstream" {
  count = var.cluster_create ? 1 : 0

  project = var.project_id

  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnet

  datapath_provider = "ADVANCED_DATAPATH"
  networking_mode   = "VPC_NATIVE"

  release_channel {
    channel = "STABLE"
  }

  deletion_protection = false

  remove_default_node_pool = true

  enable_kubernetes_alpha = false
  enable_tpu              = false

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  network_policy {
    enabled = false
  }

  // This is about adding new node pools to the cluster, _not_ about scaling the existing pools.
  cluster_autoscaling {
    enabled = false
  }

  vertical_pod_autoscaling {
    enabled = false
  }

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_global_access_config {
      enabled = true
    }
  }

  database_encryption {
    key_name = ""
    state    = "DECRYPTED"
  }

  dynamic "workload_identity_config" {
    for_each = var.wif_create ? [1] : []

    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  // This Node Pool will be deleted immediately after creation, due to
  // remove_default_node_pool, so we're just giving it enough configuration
  // for it to come up with the correct service account.
  node_pool {
    name               = "default-pool"
    initial_node_count = 1

    autoscaling {
      total_min_node_count = 1
      total_max_node_count = 1
    }

    node_config {
      image_type      = "COS_CONTAINERD"
      machine_type    = var.machine_type
      service_account = google_service_account.bufstream_cluster[0].email
    }
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

resource "google_container_node_pool" "default_pool" {
  count = var.cluster_create ? 1 : 0

  project = var.project_id

  name     = "${var.cluster_name}-pool"
  location = var.region

  cluster = local.cluster_ref

  initial_node_count = var.min_node_count

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  autoscaling {
    total_min_node_count = var.min_node_count
    total_max_node_count = var.max_node_count
  }

  node_config {
    service_account  = google_service_account.bufstream_cluster[0].email
    preemptible      = false
    image_type       = "COS_CONTAINERD"
    machine_type     = var.machine_type
    min_cpu_platform = ""

    metadata = {
      disable-legacy-endpoints = true
      block-project-ssh-keys   = true
    }

    local_ssd_count = 0
    disk_size_gb    = 100

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    boot_disk_kms_key = ""

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = ["gke-${var.cluster_name}"]
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

resource "google_service_account" "bufstream" {
  count = var.service_account_create ? 1 : 0

  project = var.project_id

  account_id   = var.service_account_name
  display_name = "Bufstream Service Account"
  description  = "Bufstream Service Account"
}

data "google_service_account" "bufstream" {
  count = var.service_account_create ? 0 : 1

  project = var.project_id

  account_id = var.service_account_name
}

resource "google_service_account_iam_binding" "k8s_bindings" {
  count = var.wif_create ? 1 : 0

  service_account_id = local.bufstream_sa_ref
  role               = "roles/iam.workloadIdentityUser"

  members = ["serviceAccount:${var.project_id}.svc.id.goog[${var.wif_bufstream_k8s_namespace}/${var.wif_bufstream_k8s_service_account}]"]
}

# Allow an internal load balancer to hit the cluster.
resource "google_compute_firewall" "allow_internal_lb_ingress" {
  count = (var.cluster_create && var.ilb_firewall_cidr != null) ? 1 : 0

  project = var.project_id

  name        = "gke-${var.cluster_name}-internal-lb-ingress"
  description = "Allow an internal load balancer to hit the cluster"
  network     = var.network
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [var.ilb_firewall_cidr]
  target_tags   = ["gke-${var.cluster_name}"]

  # Allow all possible ports
  allow { protocol = "tcp" }
}
