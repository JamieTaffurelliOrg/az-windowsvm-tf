variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "location" {
  type        = string
  description = "Location of the Virtual Network"
}

variable "windows_virtual_machines" {
  type = list(object(
    {
      name                          = string
      enable_accelerated_networking = optional(bool, true)
      subnet_reference              = string
      private_ip_address_version    = optional(string, "IPv4")
      private_ip_address_allocation = optional(string, "Static")
      private_ip_address            = optional(string)
      size                          = string
      admin_username                = string
      zone                          = string
      //image_reference               = string
      source_image = object(
        {
          publisher = string
          offer     = string
          sku       = string
        }
      )
      enable_automatic_updates = optional(bool, false)
      hotpatching_enabled      = optional(bool, false)
      patch_assessment_mode    = optional(string, "ImageDefault")
      patch_mode               = optional(string, "Manual")
      timezone                 = string
      os_disk_size_gb          = optional(number, 127)
      disks = optional(list(object({
        name         = string
        disk_size_gb = number
        lun          = number
        caching      = optional(string, "None")
      })), [])
      sql = optional(object(
        {
          data_file_path = string
          data_luns      = list(number)
          log_file_path  = string
          log_luns       = list(number)
        }
      ))
    }
  ))
  description = "Windows virtual machines to deploy"
}

variable "subnets" {
  type = list(object(
    {
      name                 = string
      virtual_network_name = string
      resource_group_name  = string
    }
  ))
  description = "Subnets to deploy to"
}

variable "password_key_vault_name" {
  type        = string
  description = "Name of the Key Vault to place admin passwords"
}

variable "password_key_vault_resource_group_name" {
  type        = string
  description = "Resource Group name of the Key Vault to place admin passwords"
}

/*variable "shared_images" {
  type = list(object(
    {
      name                                     = string
      shared_image_gallery_name                = string
      shared_image_gallery_resource_group_name = string
    }
  ))
  description = "The shared images to use for deploying virtual machines"
}*/

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "storage_account_name" {
  type        = string
  description = "Name of Storage Account to send diagnostics"
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "Resource Group of Storage Account to send diagnostics"
}

/*variable "data_collection_rule_name" {
  type        = string
  description = "Name of data collection rule to send diagnostics"
}

variable "data_collection_rule_resource_group_name" {
  type        = string
  description = "Resource Group of data collection rule to send diagnostics"
}*/

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
