# az-windowsvm-tf
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.39.1 |
| <a name="provider_azurerm.logs"></a> [azurerm.logs](#provider\_azurerm.logs) | 3.39.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.sql_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_managed_disk.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_monitor_diagnostic_setting.network_interface_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.virtual_machine_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.backend_address_pool_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_virtual_machine_data_disk_attachment.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.aad_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.av](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.bg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.gh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.mma](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.nwa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.pol](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.sql_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_key_vault.password_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_lb.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/lb) | data source |
| [azurerm_lb_backend_address_pool.backend_address_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/lb_backend_address_pool) | data source |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Backend address pools to join NIC | <pre>list(object(<br>    {<br>      name                    = string<br>      load_balancer_reference = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | Load balancers to join NIC to backen address pool | <pre>list(object(<br>    {<br>      name                = string<br>      resource_group_name = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the Virtual Network | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | Resource Group of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_password_key_vault_name"></a> [password\_key\_vault\_name](#input\_password\_key\_vault\_name) | Name of the Key Vault to place admin passwords | `string` | n/a | yes |
| <a name="input_password_key_vault_resource_group_name"></a> [password\_key\_vault\_resource\_group\_name](#input\_password\_key\_vault\_resource\_group\_name) | Resource Group name of the Key Vault to place admin passwords | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name to deploy to | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to deploy to | <pre>list(object(<br>    {<br>      name                 = string<br>      virtual_network_name = string<br>      resource_group_name  = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | n/a | yes |
| <a name="input_windows_virtual_machines"></a> [windows\_virtual\_machines](#input\_windows\_virtual\_machines) | Windows virtual machines to deploy | <pre>list(object(<br>    {<br>      name                           = string<br>      enable_accelerated_networking  = optional(bool, true)<br>      subnet_reference               = string<br>      private_ip_address_version     = optional(string, "IPv4")<br>      private_ip_address_allocation  = optional(string, "Static")<br>      private_ip_address             = optional(string)<br>      backend_address_pool_reference = optional(string)<br>      size                           = string<br>      admin_username                 = string<br>      zone                           = string<br>      //image_reference               = string<br>      source_image = object(<br>        {<br>          publisher = string<br>          offer     = string<br>          sku       = string<br>        }<br>      )<br>      enable_automatic_updates = optional(bool, false)<br>      hotpatching_enabled      = optional(bool, false)<br>      patch_assessment_mode    = optional(string, "ImageDefault")<br>      patch_mode               = optional(string, "Manual")<br>      timezone                 = string<br>      os_disk_size_gb          = optional(number, 127)<br>      disks = optional(list(object({<br>        name         = string<br>        disk_size_gb = number<br>        lun          = number<br>        caching      = optional(string, "None")<br>      })), [])<br>      sql = optional(object(<br>        {<br>          data_file_path = string<br>          data_luns      = list(number)<br>          log_file_path  = string<br>          log_luns       = list(number)<br>        }<br>      ))<br>    }<br>  ))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_interfaces"></a> [network\_interfaces](#output\_network\_interfaces) | The deployed network interfaces |
| <a name="output_virtual_machines"></a> [virtual\_machines](#output\_virtual\_machines) | The deployed Windows virtual machines |
<!-- END_TF_DOCS -->
