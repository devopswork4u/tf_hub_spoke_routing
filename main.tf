provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }

  required_version = ">= 1.1.0"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.2"
  # Suffix applied to all names: workload, entity, env, region
  suffix = ["${var.environment}", "${var.azure_short_location}"]
}

#--[ RESOURCE GROUP (RG) ]--------------------------------------------------------------------------------------------------------------

module "resource_group" {
  for_each    = var.global_details
  source      = "./modules/resource_group"
  rg_name     = "${module.naming.resource_group.name}-${each.key}"
  environment = var.environment
  tags        = local.common_tags
  location    = var.location
}



# #--[ VIRTUAL NETWORK (VNET) ]--------------------------------------------------------------------------------------------------------------

module "virtual_network" {
  for_each      = var.global_details
  source        = "./modules/virtual_network"
  vnet_name     = "${module.naming.virtual_network.name}-${each.key}"
  tags          = local.common_tags
  rg_name       = module.resource_group[each.key].name
  location      = var.location
  address_space = [each.value.address_space]
  depends_on    = [module.resource_group]

}

# #--[ SUBNETs (SUBNET) ]--------------------------------------------------------------------------------------------------------------

module "subnets" {
  source                = "./modules/subnet"
  for_each              = var.global_details
  subnet_name           = "${module.naming.subnet.name}-${each.key}"
  rg_name               = module.resource_group[each.key].name
  vnet_name             = module.virtual_network[each.key].name
  snet_address_prefixes = [each.value.subnet]
  tags                  = local.common_tags
  depends_on            = [module.virtual_network]

}

# #--[Public IP for Conn VM]]--------------------------------------------------------------------------------------------------------------

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${module.naming.public_ip.name}"
  location            = var.location
  resource_group_name = module.resource_group["hub01"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# #--[ NETWORK INTERFACE CARD (NICs) ]--------------------------------------------------------------------------------------------------------------

module "network_interface" {
  for_each     = var.global_details
  nic_name     = "${module.naming.network_interface.name}-${each.key}"
  source       = "./modules/network_interface"
  rg_name      = module.resource_group[each.key].name
  tags         = local.common_tags
  location     = var.location
  subnet_id    = module.subnets[each.key].id
  public_ip_id = each.key == "hub01" ? azurerm_public_ip.vm_public_ip.id : null
  depends_on   = [module.subnets]
}


# #--[ NETWORK SECURITY GROUP  (NSGs) ]--------------------------------------------------------------------------------------------------------------

module "network_groups" {
  for_each   = var.global_details
  source     = "./modules/network_security_group"
  nsg_name   = "${module.naming.network_security_group.name}-${each.key}"
  rg_name    = module.resource_group[each.key].name
  location   = var.location
  tags       = local.common_tags
  depends_on = [module.resource_group]
}


# #--[ Virtual Machine Windows (VM) ]--------------------------------------------------------------------------------------------------------------

module "windows_vm" {
  for_each       = var.global_details
  source         = "./modules/virtual_machine_windows"
  vm_name        = "wvm-${each.key}-${var.environment}"
  rg_name        = module.resource_group[each.key].name
  nic_id         = [module.network_interface[each.key].id]
  vm_size        = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password
  location       = var.location
  tags           = local.common_tags
  depends_on     = [module.resource_group, module.network_interface]
}

# #--[ Virtual Machine Windows (VM) ]--------------------------------------------------------------------------------------------------------------

module "linux_vm" {
  for_each       = var.enable_linux_vm ? var.global_details : {}
  source         = "./modules/virtual_machine_linux"
  vm_name        = "lvm-${each.key}-${var.environment}"
  rg_name        = module.resource_group[each.key].name
  nic_id         = [module.network_interface[each.key].id]
  vm_size        = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password
  tags           = local.common_tags
  location       = var.location
  depends_on     = [module.resource_group, module.network_interface]
}

# #--[ VNET Peering ]--------------------------------------------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "peer-mgmteus-to-connHub" {
  name                         = "peer-mgmteus-${var.environment}-to-connHub"
  resource_group_name          = module.resource_group["spoke01"].name
  virtual_network_name         = module.virtual_network["spoke01"].name
  remote_virtual_network_id    = module.virtual_network["hub01"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [module.virtual_network, module.resource_group]
}


resource "azurerm_virtual_network_peering" "peer-connHub-to-mgmteus" {
  name                         = "peer-connHub-${var.environment}-to-mgmteus"
  resource_group_name          = module.resource_group["hub01"].name
  virtual_network_name         = module.virtual_network["hub01"].name
  remote_virtual_network_id    = module.virtual_network["spoke01"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [module.virtual_network, module.resource_group]
}

resource "azurerm_virtual_network_peering" "peer-ideneus-to-connHub" {
  name                         = "peer-ideneus-${var.environment}-to-connHub"
  resource_group_name          = module.resource_group["spoke02"].name
  virtual_network_name         = module.virtual_network["spoke02"].name
  remote_virtual_network_id    = module.virtual_network["hub01"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [module.virtual_network, module.resource_group]
}


resource "azurerm_virtual_network_peering" "peer-connHub-to-ideneus" {
  name                         = "peer-connHub-${var.environment}-to-ideneus"
  resource_group_name          = module.resource_group["hub01"].name
  virtual_network_name         = module.virtual_network["hub01"].name
  remote_virtual_network_id    = module.virtual_network["spoke02"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  depends_on                   = [module.virtual_network, module.resource_group]
}