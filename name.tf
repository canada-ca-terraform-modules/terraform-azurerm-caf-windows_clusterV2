locals {
  name_regex          = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters  name: \/"'[]:|<>+=;,?*@&
  env_4               = substr(var.env, 0, 4)
  serverType_3        = substr(var.serverType, 0, 3)
  userDefinedString_7 = substr(var.userDefinedString, 0, 7)
  as-name             = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}-as", local.name_regex, "")

  # Pre-refactor load balancer naming formula (this module's own inline
  # azurerm_lb* resources used this before being wrapped in the load_balancer
  # child module). Kept solely as the backward-compat default for
  # load_balancer's own `custom_name`/`*_name` override arguments (see
  # loadbalancer.tf) - existing "1.0.0"-era deployments must resolve to this
  # exact name to avoid being destroyed and recreated when upgrading to the
  # module-wrapped load balancer.
  #
  # lb_name_prefix (no "-lb" suffix) feeds load_balancer's own `custom_name`
  # argument, since that module appends its own "-lb" suffix on top of
  # whatever `custom_name` resolves to - passing the full lb-name (below)
  # there would double up the suffix ("...-lb-lb"). lb-name (with the "-lb"
  # already included) is used as-is by every *sub*-resource compat default
  # (probe/pool/rule/frontend), matching the old inline formulas exactly.
  lb_name_prefix = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_7}", local.name_regex, "")
  lb-name        = "${local.lb_name_prefix}-lb"
}
