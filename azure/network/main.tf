locals {
  vpc_ref            = var.vpc_create ? azurerm_virtual_network.network[0] : data.azurerm_virtual_network.network[0]
  cluster_subnet_ref = var.cluster_subnet_create ? azurerm_subnet.cluster[0] : data.azurerm_subnet.cluster[0]
  pods_subnet_ref    = var.pods_subnet_create ? azurerm_subnet.pods[0] : data.azurerm_subnet.pods[0]
}

resource "azurerm_virtual_network" "network" {
  count = var.vpc_create ? 1 : 0

  name                = var.vpc_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
}

data "azurerm_virtual_network" "network" {
  count = var.vpc_create ? 0 : 1

  name                = var.vpc_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "cluster" {
  count = var.cluster_subnet_create ? 1 : 0

  name             = var.cluster_subnet_name
  address_prefixes = [var.cluster_subnet_cidr]

  virtual_network_name = local.vpc_ref.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "cluster" {
  count = var.cluster_subnet_create ? 0 : 1

  name                 = var.cluster_subnet_name
  virtual_network_name = local.vpc_ref.name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet" "pods" {
  count = var.pods_subnet_create ? 1 : 0

  name             = var.pods_subnet_name
  address_prefixes = [var.pods_subnet_cidr]

  virtual_network_name = local.vpc_ref.name
  resource_group_name  = var.resource_group_name

  delegation {
    name = "aks-delegation"

    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

data "azurerm_subnet" "pods" {
  count = var.pods_subnet_create ? 0 : 1

  name                 = var.pods_subnet_name
  virtual_network_name = local.vpc_ref.name
  resource_group_name  = var.resource_group_name
}
