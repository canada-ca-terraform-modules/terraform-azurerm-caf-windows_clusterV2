locals {
  resource_group_name = strcontains(var.windows_vms_cluster.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.windows_vms_cluster.resource_group) :  var.resource_groups[var.windows_vms_cluster.resource_group].name
}