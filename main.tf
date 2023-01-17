resource "azurerm_network_interface" "nic" {
  for_each                      = { for k in var.windows_virtual_machines : k.name => k }
  name                          = "${each.key}-nic-1"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  enable_ip_forwarding          = false
  enable_accelerated_networking = each.value["enable_accelerated_networking"]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.subnet[(each.value["subnet_reference"])].id
    private_ip_address_version    = each.value["private_ip_address_version"]
    private_ip_address_allocation = each.value["private_ip_address_allocation"]
    primary                       = true
    private_ip_address            = each.value["private_ip_address"]
  }
  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "network_interface_diagnostics" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_network_interface.nic[(each.key)].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "random_password" "admin_password" {
  for_each         = { for k in var.windows_virtual_machines : k.name => k }
  length           = 16
  special          = true
  lower            = true
  numeric          = true
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "!^(){}[]-_=+"
}

resource "azurerm_key_vault_secret" "admin_password" {
  for_each        = { for k in var.windows_virtual_machines : k.name => k }
  name            = each.key
  value           = random_password.admin_password[(each.key)].result
  key_vault_id    = data.azurerm_key_vault.password_kv.id
  content_type    = "password"
  expiration_date = timeadd(timestamp(), "8760h")

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = { for k in var.windows_virtual_machines : k.name => k }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = each.value["size"]
  admin_username      = each.value["admin_username"]
  admin_password      = azurerm_key_vault_secret.admin_password[(each.key)].value
  network_interface_ids = [
    azurerm_network_interface.nic[(each.key)].id
  ]
  zone                       = each.value["zone"]
  source_image_id            = data.azurerm_shared_image.image[(each.value["image_reference"])].id
  allow_extension_operations = true
  enable_automatic_updates   = false
  timezone                   = each.value["timezone"]

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.diag.primary_blob_endpoint
  }

  os_disk {
    name                 = "${each.key}-osdisk-1"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = each.value["os_disk_size_gb"]
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
  tags = var.tags
}

resource "azurerm_managed_disk" "disk" {
  for_each             = { for k in local.disks : "${k.vm_name}-${k.disk_name}" => k if k != null }
  name                 = each.key
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value["disk_size_gb"]
  zone                 = azurerm_windows_virtual_machine.vm[(each.value["vm_name"])].zone
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  for_each           = { for k in local.disks : "${k.vm_name}-${k.disk_name}" => k if k != null }
  managed_disk_id    = azurerm_managed_disk.disk[(each.key)].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[(each.value["vm_name"])].id
  lun                = each.value["lun"]
  caching            = each.value["caching"]
}

resource "azurerm_virtual_machine_extension" "mma" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings           = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.logs.workspace_id}"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.logs.primary_shared_key}"
    }
PROTECTED_SETTINGS
  tags               = var.tags
}

resource "azurerm_virtual_machine_extension" "dep" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  tags                       = var.tags
  depends_on                 = [azurerm_virtual_machine_extension.mma]
}

resource "azurerm_virtual_machine_extension" "pol" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags
  depends_on                 = [azurerm_virtual_machine_extension.mma]
}

resource "azurerm_virtual_machine_extension" "av" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "IaaSAntimalware"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.5"
  auto_upgrade_minor_version = true

  settings   = <<SETTINGS
    {
      "AntimalwareEnabled": "true",
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
        "isEnabled": "true",
        "scanType": "Quick",
        "day": "7",
        "time": "120"
      }
    }
SETTINGS
  tags       = var.tags
  depends_on = [azurerm_virtual_machine_extension.mma]
}

resource "azurerm_virtual_machine_extension" "nwa" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "NetworkWatcherAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  tags                       = var.tags
  depends_on                 = [azurerm_virtual_machine_extension.mma]
}

/*resource "azurerm_resource_group_template_deployment" "data_collection" {
  name                = "data-collection-${var.virtual_machine_name}"
  resource_group_name = var.resource_group_name
  template_content    = file("arm/vmDataCollectionRuleAssociation.json")
  parameters_content = jsonencode({
    "vmName" = {
      value = azurerm_windows_virtual_machine.vm.name
    },
    "associationName" = {
      value = "VM-Health-Dcr-Association"
    },
    "dataCollectionRuleId" = {
      value = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.data_collection_rule_resource_group_name}/providers/Microsoft.Insights/dataCollectionRules/${var.data_collection_rule_name}"
    }
  })
  deployment_mode = "Incremental"
  depends_on      = [azurerm_virtual_machine_extension.logs]
}*/

resource "azurerm_virtual_machine_extension" "gh" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "GuestHealthWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.Azure.Monitor.VirtualMachines.GuestHealth"
  type                       = "GuestHealthWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.tags
  //depends_on                 = [azurerm_resource_group_template_deployment.data_collection]
}

resource "azurerm_virtual_machine_extension" "bg" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k }
  name                       = "BGInfo"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  publisher                  = "Microsoft.Compute"
  type                       = "BGInfo"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "random_password" "sql_admin_password" {
  for_each         = { for k in var.windows_virtual_machines : k.name => k if k.sql != null }
  length           = 16
  special          = true
  lower            = true
  numeric          = true
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "!^(){}[]-_=+"
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  for_each        = { for k in var.windows_virtual_machines : k.name => k if k.sql != null }
  name            = "${each.key}-sql"
  value           = random_password.sql_admin_password[(each.key)].result
  key_vault_id    = data.azurerm_key_vault.password_kv.id
  content_type    = "password"
  expiration_date = timeadd(timestamp(), "8760h")

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "azurerm_mssql_virtual_machine" "vm" {
  for_each                         = { for k in var.windows_virtual_machines : k.name => k if k.sql != null }
  virtual_machine_id               = azurerm_windows_virtual_machine.vm[(each.key)].id
  sql_license_type                 = "PAYG"
  r_services_enabled               = false
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = azurerm_key_vault_secret.sql_admin_password[(each.key)].value
  sql_connectivity_update_username = each.value["admin_username"]

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "GENERAL"

    data_settings {
      default_file_path = each.value.sql["data_file_path"]
      luns              = each.value.sql["data_lun"]
    }

    log_settings {
      default_file_path = each.value.sql["log_file_path"]
      luns              = each.value.sql["log_lun"]
    }
  }

  depends_on = [azurerm_virtual_machine_data_disk_attachment.disk]

  lifecycle {
    ignore_changes = [
      sql_connectivity_update_password
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "virtual_machine_diagnostics" {
  for_each                   = { for k in var.windows_virtual_machines : k.name => k if k.sql != null }
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_windows_virtual_machine.vm[(each.key)].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
