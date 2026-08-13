# moved.tf
# Preserves existing state addresses across the inline-load-balancer-resources
# -> wrapped `load_balancer` child module refactor. That refactor happened in
# an earlier, untagged commit predating the azurerm 5.0.1 upgrade (v2.0.0) -
# real callers still pinned to this module's actual last published release
# ("1.0.0", which still used inline azurerm_lb* resources) would otherwise
# have their entire load balancer destroyed and recreated on upgrading
# straight to v2.0.0, found via a live terraform-module-upgrade-probe run.
#
# Each pair below shares the same `count`/`for_each` shape on both sides
# (module.load_balancer's own `count` mirrors the old inline resources'
# `count`; for_each keys are unchanged) - Terraform matches instances
# structurally, so no explicit index/key is needed in either address.

moved {
  from = azurerm_lb.loadbalancer[0]
  to   = module.load_balancer[0].azurerm_lb.loadbalancer
}

moved {
  from = azurerm_lb_backend_address_pool.loadbalancer-lbbp[0]
  to   = module.load_balancer[0].azurerm_lb_backend_address_pool.loadbalancer-lbbp
}

moved {
  from = azurerm_lb_probe.loadbalancer-lbhp
  to   = module.load_balancer[0].azurerm_lb_probe.loadbalancer-lbhp
}

moved {
  from = azurerm_lb_rule.loadbalancer-lbr
  to   = module.load_balancer[0].azurerm_lb_rule.loadbalancer-lbr
}
