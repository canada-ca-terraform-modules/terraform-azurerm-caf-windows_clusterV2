module "load_balancer" {
  count = try(var.windows_vms_cluster.lb, null) != null ? 1 : 0
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  group             = var.group
  project           = var.project
  load_balancer      = var.windows_vms_cluster.lb
  custom_data       = try(var.windows_vms_cluster.lb.custom_data, false) != false ? base64encode(file("${path.cwd}/${var.windows_vms_cluster.lb.custom_data}")) : null
  user_data         = try(var.windows_vms_cluster.lb.user_data, false) != false ? base64encode(file("${path.cwd}/${var.windows_vms_cluster.lb.user_data}")) : null
}