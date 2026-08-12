module "load_balancer" {
  count  = try(var.windows_vms_cluster.lb, null) != null ? 1 : 0
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v2.0.0"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  load_balancer     = var.windows_vms_cluster.lb
  # NOTE: group, project, custom_data, user_data were removed as unsupported
  # arguments in load_balancer v2.0.0 (dead pass-through, never consumed by
  # that module) - do not re-add.
}
