resource azurerm_availability_set availability_set {
  name                         = local.as-name
  location                     = var.location
  resource_group_name          = local.resource_group_name
  
  platform_fault_domain_count  = try(var.windows_vms_cluster.as.platform_fault_domain_count,null)
  platform_update_domain_count = try(var.windows_vms_cluster.as.platform_update_domain_count,null)
  proximity_placement_group_id = try(var.windows_vms_cluster.as.proximity_placement_group_id, null)
  managed                      = try(var.windows_vms_cluster.as.platform_managed,null)
  tags                         = var.tags

}