output "network_interfaces" {
  value       = azurerm_network_interface.nic
  description = "The deployed network interfaces"
}

output "virtual_machines" {
  value       = azurerm_windows_virtual_machine.vm
  sensitive   = true
  description = "The deployed Windows virtual machines"
}
