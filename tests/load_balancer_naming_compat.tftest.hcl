# tests/load_balancer_naming_compat.tftest.hcl
# Backward-compat naming coverage (Pattern 10: explicit override > legacy
# formula) for the load_balancer child module (v2.0.0). That module's own
# naming formula (env/userDefinedString/postfix-based) does not match this
# module's pre-refactor inline-resource naming (env/serverType/
# userDefinedString-based, used before the load balancer was wrapped in a
# child module) - without the compat defaults in loadbalancer.tf/name.tf,
# ANY existing "1.0.0"-era deployment would have its entire load balancer
# destroyed and recreated on upgrading straight to v2.0.0. Confirmed via a
# live terraform-module-upgrade-probe run comparing a real "1.0.0" deployment
# against v2.0.0 before this fix (Plan: 5 to add, 5 to destroy) and after
# (Plan: 0 to add, 0 to destroy - only benign in-place updates).

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

run "legacy_naming_defaults_applied_when_no_override_set" {
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
        probes = {
          tcp443 = {
            port = 443
          }
        }
        rules = {
          tcp443 = {
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
    condition     = module.load_balancer[0].loadbalancer.name == "Dev1SWJ-test-lb"
    error_message = "Load balancer name must default to this module's pre-refactor naming formula (env+serverType-userDefinedString-lb) when no custom_name override is set"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_address_pool.name == "Dev1SWJ-test-lb-HA-lbbp"
    error_message = "Backend address pool name must default to the pre-refactor naming formula"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_health_probe["tcp443"].name == "Dev1SWJ-test-lb-tcp443-lbhp"
    error_message = "Probe name must default to the pre-refactor naming formula"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_rule["tcp443"].name == "Dev1SWJ-test-lb-tcp443-lbr"
    error_message = "Rule name must default to the pre-refactor naming formula"
  }
}

run "explicit_override_takes_priority_over_legacy_default" {
  command = plan
  variables {
    windows_vms_cluster = {
      resource_group = "Project"
      lb = {
        resource_group_name       = "Project"
        postfix                   = "01"
        custom_name               = "existing-prod-lb"
        backend_address_pool_name = "existing-prod-lbbp"
        frontend_ip_configuration = {
          feipc1 = {
            subnet                        = "OZ"
            private_ip_address_allocation = "Dynamic"
          }
        }
        probes = {
          tcp443 = {
            name = "existing-prod-lbhp"
            port = 443
          }
        }
        rules = {
          tcp443 = {
            name                           = "existing-prod-lbr"
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
    condition     = module.load_balancer[0].loadbalancer.name == "existing-prod-lb-lb"
    error_message = "An explicit custom_name override must take priority over the legacy-formula default (load_balancer's own module appends its own -lb suffix on top of custom_name)"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_address_pool.name == "existing-prod-lbbp"
    error_message = "An explicit backend_address_pool_name override must take priority over the legacy-formula default"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_health_probe["tcp443"].name == "existing-prod-lbhp"
    error_message = "An explicit probe name override must take priority over the legacy-formula default"
  }
  assert {
    condition     = module.load_balancer[0].loadbalancer_backend_rule["tcp443"].name == "existing-prod-lbr"
    error_message = "An explicit rule name override must take priority over the legacy-formula default"
  }
}
