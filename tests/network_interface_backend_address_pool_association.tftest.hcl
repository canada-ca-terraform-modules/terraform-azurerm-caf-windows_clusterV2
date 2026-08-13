# tests/network_interface_backend_address_pool_association.tftest.hcl
# Coverage for azurerm_network_interface_backend_address_pool_association.LB_VMs
# and the module.load_balancer conditional creation this module owns directly.

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

run "association_absent_when_lb_null" {
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
    condition     = length(module.load_balancer) == 0
    error_message = "module.load_balancer must not be created when windows_vms_cluster.lb is absent"
  }
  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.LB_VMs) == 0
    error_message = "No NIC-to-backend-pool association must be created when windows_vms_cluster.lb is absent"
  }
}

run "association_created_when_lb_present" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      lb = {
        resource_group_name = "Project"
        postfix             = "01"
        frontend_ip_configuration = {
          feipc1 = {
            subnet                        = "OZ"
            private_ip_address_allocation = "Dynamic"
          }
        }
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
    condition     = length(module.load_balancer) == 1
    error_message = "module.load_balancer must be created when windows_vms_cluster.lb is present"
  }
  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.LB_VMs) == 1
    error_message = "Exactly one NIC-to-backend-pool association must be created per VM in windows_vms_cluster.windows_VMs when lb is present"
  }
  assert {
    condition     = azurerm_network_interface_backend_address_pool_association.LB_VMs["test"].ip_configuration_name == "Dev1SWJ-test-ipconfig1"
    error_message = "ip_configuration_name must match the child module's generated NIC IP configuration name"
  }
}
