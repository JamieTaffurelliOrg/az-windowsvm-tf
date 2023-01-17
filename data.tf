//data "azurerm_client_config" "current" {}

data "azurerm_subnet" "subnet" {
  for_each             = { for k in var.subnets : k.name => k }
  name                 = each.key
  virtual_network_name = each.value["virtual_network_name"]
  resource_group_name  = each.value["resource_group_name"]
}

data "azurerm_key_vault" "password_kv" {
  name                = var.password_key_vault_name
  resource_group_name = var.password_key_vault_resource_group_name
}

data "azurerm_shared_image" "image" {
  provider            = azurerm.images
  for_each            = { for k in var.shared_images : k.name => k }
  name                = each.key
  gallery_name        = each.value["shared_image_gallery_name"]
  resource_group_name = each.value["shared_image_gallery_resource_group_name"]
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}

data "azurerm_storage_account" "diag" {
  provider            = azurerm.logs
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}
