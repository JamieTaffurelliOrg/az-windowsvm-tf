locals {
  disks = distinct(flatten([
    for vm in var.windows_virtual_machines : [
      for disk in vm.disks : {
        vm_name      = vm.name
        disk_name    = disk.name
        disk_size_gb = disk.disk_size_gb
        zone         = vm.zone
        lun          = disk.lun
        caching      = disk.caching
      }
  ]]))
}
