provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "medline" {
  name                      = "stor${var.medline_default_location}${var.environment}${var.project-name}"
  resource_group_name       = data.azurerm_resource_group.medline.name
  location                  = data.azurerm_resource_group.medline.location
  account_kind              = "StorageV2"
  is_hns_enabled            = var.data_lake_enabled
  enable_https_traffic_only = true
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = var.access_tier
  min_tls_version           = "TLS1_2"


  dynamic "network_rules" {
    for_each = var.network_rules
    content {
      default_action = var.network_rule_default_action
    }
  }

  dynamic "static_website" {
    for_each = var.static_website
    content {
      index_document     = lookup(static_website.value, "index_document", "")
      error_404_document = lookup(static_website.value, "error_404_document", "")
    }
  }

  blob_properties {
    container_delete_retention_policy {
      days = var.retention
    }

    delete_retention_policy {
      days = var.retention
    }

    dynamic "cors_rule" {
      for_each = var.cors_rule
      content {
        allowed_headers    = lookup(cors_rule.value, "allowed_headers", [])
        allowed_methods    = lookup(cors_rule.value, "allowed_methods", [])
        allowed_origins    = lookup(cors_rule.value, "allowed_origins", [])
        exposed_headers    = lookup(cors_rule.value, "exposed_headers", [])
        max_age_in_seconds = lookup(cors_rule.value, "max_age_in_seconds", 1800)
      }
    }

  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.default_tags, var.extra_storage_tags)
}

resource "azurerm_management_lock" "lock" {
  count      = var.environment == "prod" ? 1 : 0
  name       = "resource-storage-lock"
  scope      = azurerm_storage_account.medline.id
  lock_level = "CanNotDelete"
  notes      = "Resource is locked, Contact Administrator For Support."
}

resource "azurerm_monitor_diagnostic_setting" "medline" {
  count                      = var.diagnostic_enabled ? 1 : 0
  name                       = "diag-${azurerm_storage_account.medline.name}"
  target_resource_id         = "${azurerm_storage_account.medline.id}/blobServices/default/"
  log_analytics_workspace_id = element(data.azurerm_log_analytics_workspace.medline.*.id, count.index)

  log {
    category = "StorageRead"
    enabled  = true
  }

  log {
    category = "StorageWrite"
    enabled  = true
  }

  log {
    category = "StorageDelete"
    enabled  = true
  }

  metric {
    category = "Transaction"
    enabled  = true
    retention_policy {
      days    = 5
      enabled = true
    }
  }
}

resource "azurerm_key_vault_access_policy" "medline" {
  count        = var.CMK_enabled ? 1 : 0
  key_vault_id = element(data.azurerm_key_vault.medline.*.id, count.index)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.medline.identity.0.principal_id

  key_permissions    = ["get", "create", "list", "delete", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  count        = var.CMK_enabled ? 1 : 0
  key_vault_id = element(data.azurerm_key_vault.medline.*.id, count.index)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["get", "create", "delete", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_storage_account_customer_managed_key" "medline" {
  count              = var.CMK_enabled ? 1 : 0
  storage_account_id = azurerm_storage_account.medline.id
  key_vault_id       = element(data.azurerm_key_vault.medline.*.id, count.index)
  key_name           = var.cmk_keyname
}
