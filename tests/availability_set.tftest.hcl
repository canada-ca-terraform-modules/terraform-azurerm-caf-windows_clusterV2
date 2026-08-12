# tests/availability_set.tftest.hcl
# Coverage for the azurerm_availability_set resource this module owns directly.

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

run "naming_convention" {
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
    error_message = "Name must follow {env4}{serverType3}-{userDefinedString7}-as convention"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.platform_fault_domain_count == 2
    error_message = "platform_fault_domain_count must pass through from windows_vms_cluster.as"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.platform_update_domain_count == 2
    error_message = "platform_update_domain_count must pass through from windows_vms_cluster.as"
  }
}

run "default_values" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
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
  # NOTE: platform_fault_domain_count/platform_update_domain_count/managed are
  # provider-side SDK defaults (3/5/true), not defaults this module's own HCL
  # sets — mock_provider under `command = plan` does not materialize them (only
  # a real provider or `command = apply` would). Confirms they pass through as
  # null (letting the real provider apply its default) rather than some other
  # unintended value.
  assert {
    condition     = azurerm_availability_set.availability_set.platform_fault_domain_count == null
    error_message = "platform_fault_domain_count must be null (provider default) when windows_vms_cluster.as is absent"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.platform_update_domain_count == null
    error_message = "platform_update_domain_count must be null (provider default) when windows_vms_cluster.as is absent"
  }
  assert {
    condition     = azurerm_availability_set.availability_set.managed == null
    error_message = "managed must be null (provider default) when windows_vms_cluster.as is absent"
  }
}

run "custom_name_override" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      as = {
        name = "existing-prod-as"
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
    condition     = azurerm_availability_set.availability_set.name == "existing-prod-as"
    error_message = "as.name override must take priority over the generated name formula"
  }
}

run "resource_group_by_name" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
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
    condition     = azurerm_availability_set.availability_set.resource_group_name == "rg-project"
    error_message = "resource_group_name must resolve from resource_groups[key].name when windows_vms_cluster.resource_group is a plain key"
  }
}

run "resource_group_by_arm_id" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-direct"
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
    condition     = azurerm_availability_set.availability_set.resource_group_name == "rg-direct"
    error_message = "resource_group_name must be parsed from a full ARM resource group ID when windows_vms_cluster.resource_group looks like one"
  }
}
