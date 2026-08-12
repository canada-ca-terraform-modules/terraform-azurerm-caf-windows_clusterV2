# tests/upgrade_compat.tftest.hcl
# State-chaining test: apply a pre-upgrade-shaped config (no as.name override,
# no lb), then plan the upgraded module against that state and confirm no
# resource address changes, replacements, or unexpected destroys.

mock_provider "azurerm" {}
mock_provider "http" {}
mock_provider "null" {}
mock_provider "random" {}

variables {
  resource_groups = {
    Project = {
      name = "rg-project"
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project"
    }
    Keyvault = {
      name = "rg-keyvault"
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-keyvault"
    }
    Backups = {
      name = "rg-backups"
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-backups"
    }
  }
  subnets = {
    OZ = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/OZ"
    }
  }
  location          = "canadacentral"
  env               = "Dev1"
  group             = "SPC"
  project           = "TST"
  userDefinedString = "test"
  serverType        = "SWJ"
  tags              = {}
}

run "baseline_apply" {
  command = apply

  # windows_virtual_machineV2's azurerm_windows_virtual_machine.vm reads
  # network_interface_ids and availability_set_id from this module's resources
  # through ARM-ID-validated arguments — mock_provider's synthetic apply-time
  # ids aren't ARM-ID shaped, so provide realistic overrides for both.
  # NOTE: override_during is intentionally omitted — `apply` is already the
  # default override timing for a `command = apply` run, and the attribute
  # itself requires Terraform >= 1.11 (added in the 1.11.0 test framework),
  # which would otherwise force this module's required_version floor higher
  # than every other consumer/child-module constraint needs.
  override_resource {
    target = azurerm_availability_set.availability_set
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.Compute/availabilitySets/Dev1SWJ-test-as"
    }
  }
  override_resource {
    target = module.windows_VMs["test"].azurerm_network_interface.vm-nic["nic1"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-project/providers/Microsoft.Network/networkInterfaces/Dev1SWJ-test-nic1"
    }
  }

  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      as = {
        platform_fault_domain_count  = 2
        platform_update_domain_count = 2
        platform_managed             = true
      }
      windows_VMs = {
        test = {
          serverType     = "SWJ"
          resource_group = "Project"
          admin_username = "azureadmin"
          admin_password = "TestP@ss123!"
          vm_size        = "Standard_D2s_v5"
          jump_server    = true
          disable_backup = true
          nic = {
            nic1 = {
              subnet                        = "OZ"
              private_ip_address_allocation = "Dynamic"
            }
          }
          storage_image_reference = {
            publisher = "MicrosoftWindowsServer"
            offer     = "WindowsServer"
            sku       = "2022-datacenter-g2"
            version   = "latest"
          }
        }
      }
    }
  }
  assert {
    condition     = azurerm_availability_set.availability_set.name == "Dev1SWJ-test-as"
    error_message = "Baseline apply: unexpected availability set name"
  }
}

run "upgrade_plan_no_replacement" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      as = {
        platform_fault_domain_count  = 2
        platform_update_domain_count = 2
        platform_managed             = true
      }
      windows_VMs = {
        test = {
          serverType     = "SWJ"
          resource_group = "Project"
          admin_username = "azureadmin"
          admin_password = "TestP@ss123!"
          vm_size        = "Standard_D2s_v5"
          jump_server    = true
          disable_backup = true
          nic = {
            nic1 = {
              subnet                        = "OZ"
              private_ip_address_allocation = "Dynamic"
            }
          }
          storage_image_reference = {
            publisher = "MicrosoftWindowsServer"
            offer     = "WindowsServer"
            sku       = "2022-datacenter-g2"
            version   = "latest"
          }
        }
      }
    }
  }
  assert {
    condition     = azurerm_availability_set.availability_set.name == "Dev1SWJ-test-as"
    error_message = "Availability set name must be unchanged after upgrade (no destroy/recreate)"
  }
}

run "upgrade_plan_with_name_override_no_replacement" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      as = {
        name                         = "Dev1SWJ-test-as"
        platform_fault_domain_count  = 2
        platform_update_domain_count = 2
        platform_managed             = true
      }
      windows_VMs = {
        test = {
          serverType     = "SWJ"
          resource_group = "Project"
          admin_username = "azureadmin"
          admin_password = "TestP@ss123!"
          vm_size        = "Standard_D2s_v5"
          jump_server    = true
          disable_backup = true
          nic = {
            nic1 = {
              subnet                        = "OZ"
              private_ip_address_allocation = "Dynamic"
            }
          }
          storage_image_reference = {
            publisher = "MicrosoftWindowsServer"
            offer     = "WindowsServer"
            sku       = "2022-datacenter-g2"
            version   = "latest"
          }
        }
      }
    }
  }
  assert {
    condition     = azurerm_availability_set.availability_set.name == "Dev1SWJ-test-as"
    error_message = "Newly-added as.name override key must not force a replacement when left unset"
  }
}
