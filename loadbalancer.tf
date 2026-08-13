locals {
  # Backward-compat name defaults for the load_balancer child module (v2.0.0).
  # That module's own naming formula (env/userDefinedString/postfix-based)
  # does not match this module's pre-refactor inline-resource naming (which
  # included serverType) - without these defaults, ANY existing "1.0.0"-era
  # deployment would have its entire load balancer destroyed and recreated on
  # upgrading straight to v2.0.0 (confirmed via a live terraform-module-
  # upgrade-probe run). load_balancer v2.0.0 already exposes a `custom_name`/
  # `*_name` override on every one of these resources for exactly this kind
  # of migration - each default below only applies when the caller hasn't
  # already set their own override (explicit override > legacy formula,
  # Pattern 10 in the eslz-module-upgrade skill's compat-patterns.md).
  lb_compat_frontend_ip_configuration = {
    for key, value in try(var.windows_vms_cluster.lb.frontend_ip_configuration, {}) :
    key => merge(value, { name = try(value.name, "${local.lb-name}-${key}-lbfe") })
  }
  lb_compat_probes = {
    for key, value in try(var.windows_vms_cluster.lb.probes, {}) :
    key => merge(value, { name = try(value.name, "${local.lb-name}-${key}-lbhp") })
  }
  lb_compat_rules = {
    for key, value in try(var.windows_vms_cluster.lb.rules, {}) :
    key => merge(value, { name = try(value.name, "${local.lb-name}-${key}-lbr") })
  }
  lb_compat = try(var.windows_vms_cluster.lb, null) == null ? null : merge(
    var.windows_vms_cluster.lb,
    {
      custom_name               = try(var.windows_vms_cluster.lb.custom_name, local.lb_name_prefix)
      backend_address_pool_name = try(var.windows_vms_cluster.lb.backend_address_pool_name, "${local.lb-name}-HA-lbbp")
      frontend_ip_configuration = local.lb_compat_frontend_ip_configuration
      probes                    = local.lb_compat_probes
      rules                     = local.lb_compat_rules
    }
  )
}

module "load_balancer" {
  count  = try(var.windows_vms_cluster.lb, null) != null ? 1 : 0
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v2.0.0"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  load_balancer     = local.lb_compat
  # NOTE: group, project, custom_data, user_data were removed as unsupported
  # arguments in load_balancer v2.0.0 (dead pass-through, never consumed by
  # that module) - do not re-add.
}
