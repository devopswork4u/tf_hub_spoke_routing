terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "resource_id" {
  type        = string
  description = "(Required) Resource ID of diagnotics to be enabled"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "(Optional) Log Analytics Workspace ID where diagnotics will be logged to"
}

data "azurerm_monitor_diagnostic_categories" "monitor_diagnostic_categories" {
  resource_id = var.resource_id
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  name                       = "diagsetting"
  target_resource_id         = var.resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id


  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.monitor_diagnostic_categories.metrics)
    content {
      category = metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.monitor_diagnostic_categories.log_category_types)

    content {
      category = enabled_log.value
    }
  }
  lifecycle {
    ignore_changes = [metric, enabled_log]
  }
}

# Outputs
output "monitor_diagnostic_setting" {
  value = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting
}
output "id" {
  value = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting.id
}
