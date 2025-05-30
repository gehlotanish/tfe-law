data "azurerm_resource_group" "medline" {
  name = var.azure_resource_group_name
}

data "azurerm_log_analytics_workspace" "medline" {
  count               = var.diagnostic_enabled ? 1 : 0
  name                = var.log_analytics_name
  resource_group_name = var.azure_resource_group_name
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "medline" {
  count               = var.CMK_enabled ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.azure_resource_group_name
}
