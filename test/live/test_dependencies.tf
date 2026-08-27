# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group, vnet, or
# subnet: writing into a shared RG usually requires elevated, non-sandbox
# permissions. A dedicated throwaway RG + vnet + subnet here needs only
# Contributor on the sandbox subscription and can never collide with or
# affect any production resource.
#
# The fixture's VM sets jump_server = true, which skips the child
# windows_VMs module's RSV/backup-policy data lookups entirely (see that
# module's backup.tf) - no real Recovery Services Vault or backup policy is
# needed for this harness, unlike the L2 upgrade-probe harness this was
# adapted from (which pins an older child version without that skip).

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module from
  # colliding on the same sandbox subscription.
  name     = "${var.env}-caf-windows-clusterv2-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag (ticket 13): lets the nightly orphan sweeper find this RG
  # by tag and match it back to a PR, independent of naming convention.
  tags = merge(var.tags, { "pr-number" = var.pr_number })
}

resource "azurerm_virtual_network" "live_test" {
  name                = "${var.env}-caf-windows-clusterv2-live-test-${var.pr_number}-vnet"
  address_space       = ["10.253.0.0/16"] # arbitrary, unpeered - collision-safe by construction
  location            = azurerm_resource_group.live_test.location
  resource_group_name = azurerm_resource_group.live_test.name
  tags                = var.tags
}

resource "azurerm_subnet" "live_test" {
  name                 = "${var.env}-caf-windows-clusterv2-live-test-${var.pr_number}-snet"
  resource_group_name  = azurerm_resource_group.live_test.name
  virtual_network_name = azurerm_virtual_network.live_test.name
  address_prefixes     = ["10.253.0.0/24"]
}

locals {
  # windows_clusterV2 (and the windows_VMs child module it wraps) take MAPS
  # keyed by the name the windows_vms_cluster object references
  # (resource_group = "Project", nic.subnet = "livetest").
  #
  # Keyvault is required even though no real Key Vault lookup happens here
  # (jump_server = true and no admin_password_key_vault set): the child
  # windows_VMs module's secret.tf unconditionally hashes
  # var.resource_groups["Keyvault"].id in a local regardless - the map key
  # itself must resolve or the plan fails with "Invalid index" before that
  # logic is even evaluated. Backups points at the same throwaway RG since
  # no real Recovery Services Vault is needed with jump_server = true.
  resource_groups = {
    Project  = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
    Keyvault = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
    Backups  = { name = azurerm_resource_group.live_test.name, id = azurerm_resource_group.live_test.id }
  }
  subnets = {
    livetest = { id = azurerm_subnet.live_test.id }
  }
}
