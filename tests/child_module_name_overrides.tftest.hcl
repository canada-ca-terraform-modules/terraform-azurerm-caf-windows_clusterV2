# tests/child_module_name_overrides.tftest.hcl
# Confirms the optional name-override keys newly documented in
# ESLZ/SRV-windows-cluster.tfvars (added upstream in windows_virtual_machineV2
# v1.1.0 and load_balancer v2.0.0) actually flow through this module's
# pass-through wiring to the child modules' own resources. Only each child
# module's own exposed outputs are asserted on (windows_vm_object, loadbalancer,
# loadbalancer_backend_address_pool, loadbalancer_health_probe,
# loadbalancer_backend_rule) - a nested module's internal resources are not
# addressable from an assert condition outside override_resource/moved/import.

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

run "windows_vm_name_overrides_passthrough" {
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
          vm_name        = "existing-prod-vm"
          nsg_name       = "existing-prod-vm-nsg"
          use_nic_nsg    = true
          security_rules = []
          kv_secret_name = "existing-vm-secret"
          os_disk = {
            name = "existing-prod-osdisk1"
          }
          nic = {
            nic1 = {
              subnet                        = "OZ"
              private_ip_address_allocation = "Dynamic"
              name                          = "existing-prod-nic1"
              ip_configuration_name         = "existing-prod-ipconfig1"
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
    condition     = module.windows_VMs["test"].windows_vm_object.name == "existing-prod-vm"
    error_message = "vm_name override must pass through to the windows_VMs child module's VM resource"
  }
}

run "lb_name_overrides_passthrough" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      lb = {
        resource_group_name = "Project"
        postfix             = "01"
        frontend_ip_configuration = {
          feipc1 = {
            name                          = "existing-prod-lbfe"
            subnet                        = "OZ"
            private_ip_address_allocation = "Dynamic"
          }
        }
        backend_address_pool_name = "existing-prod-lbbp"
        probes = {
          tcp443 = {
            name = "existing-prod-lbhp-443"
            port = 443
          }
        }
        rules = {
          tcp443 = {
            name                           = "existing-prod-lbr-443"
            protocol                       = "Tcp"
            frontend_port                  = 443
            backend_port                   = 443
            frontend_ip_configuration_name = "feipc1"
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
    condition     = module.load_balancer[0].loadbalancer.frontend_ip_configuration[0].name == "existing-prod-lbfe"
    error_message = "lb.frontend_ip_configuration.name override must pass through to the load_balancer child module"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_address_pool.name == "existing-prod-lbbp"
    error_message = "lb.backend_address_pool_name override must pass through to the load_balancer child module"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_health_probe["tcp443"].name == "existing-prod-lbhp-443"
    error_message = "lb.probes.name override must pass through to the load_balancer child module"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_rule["tcp443"].name == "existing-prod-lbr-443"
    error_message = "lb.rules.name override must pass through to the load_balancer child module"
  }
}
