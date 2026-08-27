windows_vms_cluster = {
  resource_group = "Project"

  as = {
    platform_fault_domain_count  = 2
    platform_update_domain_count = 2
    platform_managed             = true
  }

  windows_VMs = {
    livetest = {
      serverType     = "SWJ"
      resource_group = "Project"
      admin_username = "azureadmin"
      # Live-test-only throwaway credential, never a real target.
      admin_password = "L1v3T3st!Pr0be2026"
      # Dav6 family: the sandbox subscription's Dsv5/Dasv5 default family
      # quota hits a hard Azure capacity restriction in canadacentral;
      # Dav6 quota has already been provisioned for live-test fixtures.
      vm_size        = "Standard_D2as_v6"
      jump_server    = true
      disable_backup = true

      nic = {
        nic1 = {
          subnet                        = "livetest"
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
