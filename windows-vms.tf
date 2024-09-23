module "windows_VMs" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-windows_virtual_machineV2.git?ref=v1.0.1"
  for_each = var.windows_vms_cluster.windows_VMs

  location= var.location
  env = var.env
  group = var.group
  project = var.project
  userDefinedString = each.key
  windows_VM = merge(each.value, {availability_set_id = azurerm_availability_set.availability_set.id})
 
  resource_groups = var.resource_groups
  subnets = var.subnets
  user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
  depends_on = [azurerm_availability_set.availability_set]
}
resource "azurerm_network_interface_backend_address_pool_association" "LB_VMs" {
  for_each = var.windows_vms_cluster.lb != null ? var.windows_vms_cluster.windows_VMs : {}

  network_interface_id    =  module.windows_VMs[each.key].windows_vm_object.network_interface_ids[0]
  ip_configuration_name   =  "${module.windows_VMs[each.key].windows_vm_object.name}-ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id
}