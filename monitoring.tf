resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
 
  name                = "law-eus-${var.environment}-${var.instance_number}"
  location            = var.location
  resource_group_name = module.resource_group["spoke01"].name
  sku                 = "PerGB2018"
  retention_in_days   = "30"
}

resource "azurerm_portal_dashboard" "vnet_connectivity" {
  name                = "connectivity-check-dashboard"
  resource_group_name = module.resource_group["spoke01"].name
  location            = var.location
  tags = local.common_tags

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x       = 0
              y       = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = "# VNet Connectivity Dashboard\nMonitoring VM-MGMT to VM-IDENTITY"
              }
            }
          }

          "1" = {
            position = {
              x       = 0
              y       = 4
              rowSpan = 6
              colSpan = 6
            }
            metadata = {
              type = "Extension/AnalyticsExtension/PartType/LogAnalyticsViewPart"
              settings = {
                query               = <<QUERY
NetworkMonitoring
| where TestName == "connMonitor‑MgmtToIdentity"
| summarize arg_max(TimeGenerated, Status) by TestName
| project TestName, TimeGenerated, Status
QUERY
                workspaceResourceId = azurerm_log_analytics_workspace.log_analytics_workspace.id
                visualization       = "table"
                title               = "Connection Status: MGMT → IDENTITY"
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = "1h"
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
        filterLocale     = "en-us"
        filters          = {}
        defaultFilterKey = "MsPortalFx_TimeRange"
      }
    }
  })
}




resource "azurerm_network_security_rule" "allow-all-from-identity" {
  for_each = {
    "Allow_ALL" = {
      name                       = "allow-all-idenvnet-inbound"
      description                = "Allow ALL from identity vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 101
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.191.192.0/22"
      destination_address_prefix = "*"
    }
    "allow_hub" = {
      name                       = "allow-all-connhub-inbound"
      description                = "Allow ALL from connhub vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 102
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.189.192.0/22"
      destination_address_prefix = "*"
    }
    "allow_my_ip" = {
      name                       = "allow-all-mypip-inbound"
      description                = "Allow ALL from mypip "
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 105
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "173.35.27.200"
      destination_address_prefix = "*"
    }
  }
  resource_group_name         = module.resource_group["spoke01"].name
  network_security_group_name = module.network_groups["spoke01"].name
  name                        = each.value.name
  description                 = each.value.description
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_network_security_rule" "allow-all-from-mgmt" {
  for_each = {
    "Allow_ALL" = {
      name                       = "allow-all-mgmt-inbound"
      description                = "Allow ALL from mgmt vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 101
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.190.192.0/22"
      destination_address_prefix = "*"
    }
    "allow_hub" = {
      name                       = "allow-all-connhub-inbound"
      description                = "Allow ALL from connhub vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 102
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.189.192.0/22"
      destination_address_prefix = "*"
    }
  }
  resource_group_name         = module.resource_group["spoke02"].name
  network_security_group_name = module.network_groups["spoke02"].name
  name                        = each.value.name
  description                 = each.value.description
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}


resource "azurerm_network_security_rule" "allow-spokes-to-hub" {
  for_each = {
    "Allow_mgmt" = {
      name                       = "allow-spokes-mgmt-inbound"
      description                = "Allow ALL from mgmt vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 101
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.190.192.0/22"
      destination_address_prefix = "*"
    }
    "allow_iden" = {
      name                       = "allow-spokes-iden-inbound"
      description                = "Allow ALL from iden vnet"
      direction                  = "Inbound"
      access                     = "Allow"
      priority                   = 102
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.191.192.0/22"
      destination_address_prefix = "*"
    }
  }
  resource_group_name         = module.resource_group["hub01"].name
  network_security_group_name = module.network_groups["hub01"].name
  name                        = each.value.name
  description                 = each.value.description
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}


module "vnet_diag_settings" {
  for_each = module.virtual_network

  source                     = "./modules/diag_settings"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  resource_id                = each.value.id
}

module "ngs_diag_settings" {
  for_each = module.network_groups

  source                     = "./modules/diag_settings"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  resource_id                = each.value.id
}

module "law_diag_settings" {
  source                     = "./modules/diag_settings"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  resource_id                = azurerm_log_analytics_workspace.log_analytics_workspace.id
}