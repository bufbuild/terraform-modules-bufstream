locals {
  cluster_ref      = var.cluster_create ? azurerm_kubernetes_cluster.cluster[0] : data.azurerm_kubernetes_cluster.cluster[0]
  bufstream_id_ref = var.bufstream_identity_create ? azurerm_user_assigned_identity.bufstream[0] : data.azurerm_user_assigned_identity.bufstream[0]
}

data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "cluster" {
  count = var.cluster_create ? 1 : 0

  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location

  dns_prefix = var.resource_group_name

  kubernetes_version = var.kubernetes_version

  sku_tier = "Standard"

  network_profile {
    network_plugin     = "azure"
    network_policy     = "cilium"
    network_data_plane = "cilium"

    service_cidrs  = var.cluster_service_cidrs
    dns_service_ip = var.cluster_dns_service_ip
  }

  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "defaulttmp"

    vm_size = var.cluster_vm_size

    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3

    vnet_subnet_id = var.cluster_vnet_subnet_id
    pod_subnet_id  = var.cluster_pod_subnet_id

    os_sku = "AzureLinux"

    // Defaults, if not set, causes changes after initial creation
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  automatic_upgrade_channel = "stable"
  node_os_upgrade_channel   = "NodeImage"

  # Enable AKS Managed Entra-ID authentication, with Azure RBAC
  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  oidc_issuer_enabled               = true
  role_based_access_control_enabled = true
  local_account_disabled            = true

  workload_identity_enabled = true

  # Disable legacy http application routing
  http_application_routing_enabled = false

  identity {
    type = "SystemAssigned"
  }

  run_command_enabled = true

  lifecycle {
    ignore_changes = [
      kubernetes_version,
    ]
  }
}

resource "azurerm_role_assignment" "bufstream" {
  count = var.cluster_grant_admin_to_caller ? 1 : 0

  scope                = local.cluster_ref.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_kubernetes_cluster" "cluster" {
  count = var.cluster_create ? 0 : 1

  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "bufstream" {
  count = var.bufstream_identity_create ? 1 : 0

  name                = var.bufstream_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

data "azurerm_user_assigned_identity" "bufstream" {
  count = var.bufstream_identity_create ? 0 : 1

  name                = var.bufstream_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "federated_credential" {
  count = var.wif_create ? 1 : 0

  name                = "bufstream"
  resource_group_name = var.resource_group_name

  parent_id = local.bufstream_id_ref.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = local.cluster_ref.oidc_issuer_url
  subject   = "system:serviceaccount:${var.wif_bufstream_k8s_namespace}:${var.wif_bufstream_k8s_service_account}"
}
