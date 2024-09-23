windows_vms_clusterV2 = {
    devops = {
            resource_group                = "Project"
            userDefinedString             = "test"
            windows_VMs = {
                test = {
                    serverType     = "SWJ"
                    postfix        = "01"
                    resource_group = "Project"
                    admin_username = "azureadmin"
                    # admin_password          = "Canada123!"                          # Optional: Only set the password if a generated password cannot be created. See README for details
                    # password_overwrite = true                                       # Optional: Set this to true if you absolutely want to set the admin password above
                    vm_size = "Standard_D2s_v5"

                    backup_policy = "daily1" # Optional: Set this value to configure backup policy on the VM. Can be either userDefinedString portion of the policy name or ID. Defaults to daily1 
                    # disable_backup           = false                                                                             # Optional: Set this value to true if you want to disable backups on this VM    
                    enable_automatic_updates = true                  # (Optional) Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created.
                    patch_assessment_mode    = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 
                    patch_mode               = "AutomaticByPlatform" # force settings to AutomaticByPlatform for UMC OS patching 

                    # computer_name                                          = "Example"                                           # Optional: Set this if you need the guest OS Hostname to be different than the Azure resource name
                    # user_data                                              = "post_install_scripts/ubuntu/post_install.sh"       # Optional: Set this value with the relative path to the file from your CWD.
                    # boot_diagnostic                                        = true
                    # use_nic_nsg                                            = true
                    # allow_extension_operations                             = true
                    # availability_set_id                                    = ""
                    # bypass_platform_safety_checks_on_user_schedule_enabled = false
                    # capacity_reservation_group_id                          = ""
                    # dedicated_host_id                                      = ""
                    # dedicated_host_group_id                                = ""
                    # edge_zone                                              = ""
                    # disk_controller_type                                   = ""
                    # encryption_at_host_enabled                             = ""
                    # eviction_policy                                        = ""
                    # extensions_time_budget                                 = "PT1H30M"
                    # hotpatching_enabled                                    = false
                    # license_type                                           = ""
                    # max_bid_price                                          = -1
                    # platform_fault_domain                                  = ""
                    # priority                                               = "Regular"
                    # provision_vm_agent                                     = true
                    # proximity_placement_group_id                           = ""
                    # reboot_setting                                         = "Never"
                    # secure_boot_enabled                                    = false
                    # source_image_id                                        = ""
                    # timezone                                               = "UTC-11"
                    # virtual_machine_scale_set_id                           = ""
                    # vm_agent_platform_updates_enabled                      = false
                    # vtpm_enabled                                           = ""
                    # zone                                                   = ""

                    # At least one nic is required. If more than one is present, the first nic in the list will be the primary one.
                    nic = {
                    nic1 = {
                        subnet                        = "APP"
                        private_ip_address_allocation = "Static"
                        private_ip_address            = "172.17.65.8"

                        # dns_servers                    = []
                        # edge_zone                      = ""
                        # ip_forwarding_enabled          = false
                        # accelerated_networking_enabled = false
                        # internal_dns_name_label        = ""
                    }
                    }

                    storage_image_reference = {
                    publisher = "MicrosoftWindowsServer"
                    offer     = "WindowsServer"
                    sku       = "2022-datacenter-g2"
                    version   = "latest"
                    }

                    # Optional: Uncomment if you need to configure os_disk with different defaults than below. Only supports one os_disk
                    os_disk = {
                    caching                   = "ReadWrite"
                    storage_account_type      = "Standard_LRS"
                    disk_size_gb              = 512
                    write_accelerator_enabled = false
                    }

                    # Optional: Uncomment and configure data disks for the VM. Can create more than one data disks.
                    data_disks = {
                    disk1 = {
                        storage_account_type = "StandardSSD_LRS"
                        disk_create_option   = "Empty"
                        disk_size_gb         = 500
                        lun                  = 0
                        caching              = "ReadWrite"
                        # disk_iops_read_write                 = null
                        # disk_mbps_read_write                 = null
                        # disk_iops_read_only                  = null
                        # disk_mbps_read_only                  = null
                        # upload_size_bytes                    = null
                        # edge_zone                            = null
                        # hyper_v_generation                   = null
                        # image_reference_id                   = null
                        # gallery_image_reference_id           = null
                        # logical_sector_size                  = null
                        # optimized_frequent_attach_enabled    = false
                        # performance_plus_enabled             = false
                        # os_type                              = "Windows"
                        # source_resource_id                   = null
                        # source_uri                           = null
                        # storage_account_id                   = null
                        # tier                                 = null
                        # max_shares                           = null
                        # trusted_launch_enabled               = null
                        # security_type                        = null
                        # secure_vm_disk_encryption_set_id     = null
                        # on_demand_bursting_enabled           = null
                        # zone                                 = null
                        # public_network_access_enabled        = false
                    }
                    }

                    # Optional: Uncomment this block to setup auto-shutdown on the VM.
                    auto_shutdown_config = {
                    enabled               = true
                    timezone              = "Eastern Standard Time"
                    daily_recurrence_time = "1600"

                    notification_settings = {
                        enabled         = true
                        email           = "maxime.mahdavian@ssc-spc.gc.ca"
                        time_in_minutes = 30
                    }
                    }

                    # Optional: Uncomment this if you want to set an identityfor the VM. Note that if boot_diagnostic is Enabled then a SystemAssigned identity is automatically granted to the VM. 
                    # identity = {
                    #   type         = "SystemAssigned"
                    #   identity_ids = []
                    # }


                    # Optional: Uncomment this if you want to set additional capabilities other than the default below
                    # additional_capabilities = {
                    #   ultra_ssd_enabled   = false
                    #   hibernation_enabled = false
                    # }

                    # Optional: Uncomment this if you want to set additional_unattend_content
                    # additional_unattend_content = {
                    #   content = ""
                    #   setting = ""
                    # }

                    # Optional: Uncomment this if you want to set gallery_application
                    # gallery_application = {
                    #   version_id                                  = ""
                    #   automatic_upgrade_enabled                   = false
                    #   configuration_blob_uri                      = ""
                    #   order                                       = 0
                    #   tag                                         = ""
                    #   treat_failure_as_deployment_failure_enabled = false
                    # }

                    # secret = {
                    #   certificate = {
                    #     store = ""
                    #     url   = ""
                    #   }
                    #   key_vault_id = ""
                    # }

                    # plan = {
                    #   name      = ""
                    #   product   = ""
                    #   publisher = ""
                    # }

                    # os_image_notification = {
                    #   timeout = "PT15M"
                    # }

                    # termination_notification = {
                    #   enabled = false
                    #   timeout = "PT5M"
                    # }

                    # winrm_listener = {
                    #   protocol        = ""
                    #   certificate_url = ""
                    # }

                    # load_balancer_address_pools_ids = {
                    #   "ID" = {}
                    # }

                    # asg = {
                    #   application_security_group_id = ""
                    # }

                    # Optional: Uncomment to set Network Security Rules on the VM. Only available if use_nic_nsg is set to true. 
                    # security_rules = {
                    #   test = {
                    #   name                         = "Example"
                    #   priority                     =  401
                    #   access                       = "Allow"
                    #   protocol                     = "Tcp"
                    #   direction                    = "Inbound"
                    #   source_port_ranges            = ["*"]
                    #   source_address_prefixes      = [""]
                    #   destination_port_ranges      = [""]
                    #   destination_address_prefixes = [""]
                    #   description = ""
                    #   }
                    # }
                }
            }
            lb = {
                #
                # azurerm_lb section
                #
                # edge_zone = "" # (Optional) Specifies the Edge Zone within the Azure Region where this Load Balancer should exist. Changing this forces a new Load Balancer to be created.

                frontend_ip_configuration = {
                    feipc1 = {
                    subnet                                             = "MAZ"         # (Required) The name or the resource id of the Subnet which should be used for this IP Configuration
                    # private_ip_address                                 = "10.10.10.10" # (Optional) Private IP Address to assign to the Load Balancer. The last one and first four IPs in any range are reserved and cannot be manually assigned.
                    private_ip_address_allocation                      = "Dynamic"     # (Optional) The allocation method for the Private IP Address used by this Load Balancer. Possible values as Dynamic and Static.
                    # private_ip_address_version                         = "IPv4"        # (Optional) The version of IP that the Private IP Address is. Possible values are IPv4 or IPv6.
                    # public_ip_address_id                               = ""            # (Optional) The ID of a Public IP Address which should be associated with the Load Balancer.
                    # public_ip_prefix_id                                = ""            # (Optional) The ID of a Public IP Prefix which should be associated with the Load Balancer. Public IP Prefix can only be used with outbound rules.
                    # zones                                              = [""]          # (Optional) Specifies a list of Availability Zones in which the IP Address for this Load Balancer should be located.
                    # gateway_load_balancer_frontend_ip_configuration_id = ""            # (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.
                    # Optional: Uncomment the following tag block if you want to add custom tags to the VMSS
                    # tags = {
                    #   some = "a"
                    #   new  = "b"
                    #   tag  = "c"
                    # }
                    }
                }

                # sku      = "Standard" # Optional. Default to Standard
                # sku_tier = "Regional" # (Optional) sku_tier - (Optional) The SKU tier of this Load Balancer. Possible values are Global and Regional. Defaults to Regional. Changing this forces a new resource to be created.

                #
                # azurerm_lb_backend_address_pool section
                #
                # synchronous_mode = "Automatic" # (Optional) The backend address synchronous mode for the Backend Address Pool. Possible values are Automatic and Manual. This is required with virtual_network_id. Changing this forces a new resource to be created.
                # tunnel_interface = {
                #   ti1 = {
                #     identifier = ""     # (Required) The unique identifier of this Gateway Load Balancer Tunnel Interface.
                #     type       = "None" # (Required) The traffic type of this Gateway Load Balancer Tunnel Interface. Possible values are None, Internal and External.
                #     protocol   = "None" # (Required) The protocol used for this Gateway Load Balancer Tunnel Interface. Possible values are None, Native and VXLAN.
                #     port       = 2345   # (Required) The port number that this Gateway Load Balancer Tunnel Interface listens to.
                #   }
                # }
                # virtual_network_id = "" # (Optional) The ID of the Virtual Network within which the Backend Address Pool should exist.

                #
                # azurerm_lb_probe section
                #
                probes = {
                    tcp443 = {
                    protocol        = "Tcp" # (Optional) Specifies the protocol of the end point. Possible values are Http, Https or Tcp. If TCP is specified, a received ACK is required for the probe to be successful. If HTTP is specified, a 200 OK response from the specified URI is required for the probe to be successful. Defaults to Tcp.
                    port            = 443   # (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive.
                    probe_threshold = 1     # (Optional) The number of consecutive successful or failed probes that allow or deny traffic to this endpoint. Possible values range from 1 to 100. The default value is 1.
                    # request_path        = ""    # (Optional) The URI used for requesting health status from the backend endpoint. Required if protocol is set to Http or Https. Otherwise, it is not allowed.
                    # interval_in_seconds = 15    # (Optional) The interval, in seconds between probes to the backend endpoint for health status. The default value is 15, the minimum value is 5.
                    }
                    tcp80 = {
                    protocol        = "Tcp" # (Optional) Specifies the protocol of the end point. Possible values are Http, Https or Tcp. If TCP is specified, a received ACK is required for the probe to be successful. If HTTP is specified, a 200 OK response from the specified URI is required for the probe to be successful. Defaults to Tcp.
                    port            = 80    # (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive.
                    probe_threshold = 1     # (Optional) The number of consecutive successful or failed probes that allow or deny traffic to this endpoint. Possible values range from 1 to 100. The default value is 1.
                    # request_path        = ""    # (Optional) The URI used for requesting health status from the backend endpoint. Required if protocol is set to Http or Https. Otherwise, it is not allowed.
                    # interval_in_seconds = 15    # (Optional) The interval, in seconds between probes to the backend endpoint for health status. The default value is 15, the minimum value is 5.
                    }
                }

                #
                # azurerm_lb_rule section
                #
                rules = {
                    tcp443 = {
                    protocol                       = "Tcp"    # (Required) The transport protocol for the external endpoint. Possible values are Tcp, Udp or All.
                    frontend_port                  = 443      # (Required) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 0 and 65534, inclusive. A port of 0 means "Any Port".
                    backend_port                   = 443      # (Required) The port used for internal connections on the endpoint. Possible values range between 0 and 65535, inclusive. A port of 0 means "Any Port".
                    probe_name                     = "tcp443" # (Optional) The name of a Probe defined above
                    enable_floating_ip             = true     # (Optional) Are the Floating IPs enabled for this Load Balancer Rule? A "floating” IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
                    frontend_ip_configuration_name = "feipc1" # (Requires) The name of the Frontend IP Configuration to associate with the Load Balancer Rule.
                    # idle_timeout_in_minutes        = 4                  # (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 100 minutes. Defaults to 4 minutes.
                    load_distribution = "SourceIPProtocol" #(Optional) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: Default – The load balancer is configured to use a 5 tuple hash to map traffic to available servers. SourceIP – The load balancer is configured to use a 2 tuple hash to map traffic to available servers. SourceIPProtocol – The load balancer is configured to use a 3 tuple hash to map traffic to available servers. Also known as Session Persistence, where in the Azure portal the options are called None, Client IP and Client IP and Protocol respectively. Defaults to Default.
                    # disable_outbound_snat          = false              # (Optional) Should outbound SNAT be disabled for this Load Balancer Rule? Defaults to false.
                    # enable_tcp_reset               = true               # (Optional) Is TCP Reset enabled for this Load Balancer Rule
                    },
                    tcp80 = {
                    protocol                       = "Tcp"    # (Required) The transport protocol for the external endpoint. Possible values are Tcp, Udp or All.
                    frontend_port                  = 80       # (Required) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 0 and 65534, inclusive. A port of 0 means "Any Port".
                    backend_port                   = 80       # (Required) The port used for internal connections on the endpoint. Possible values range between 0 and 65535, inclusive. A port of 0 means "Any Port".
                    probe_name                     = "tcp80"  # (Optional) The name of a Probe defined above
                    enable_floating_ip             = true     # (Optional) Are the Floating IPs enabled for this Load Balancer Rule? A "floating” IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
                    frontend_ip_configuration_name = "feipc1" # (Requires) The name of the Frontend IP Configuration to associate with the Load Balancer Rule.
                    # idle_timeout_in_minutes        = 4                  # (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 100 minutes. Defaults to 4 minutes.
                    load_distribution = "SourceIPProtocol" #(Optional) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: Default – The load balancer is configured to use a 5 tuple hash to map traffic to available servers. SourceIP – The load balancer is configured to use a 2 tuple hash to map traffic to available servers. SourceIPProtocol – The load balancer is configured to use a 3 tuple hash to map traffic to available servers. Also known as Session Persistence, where in the Azure portal the options are called None, Client IP and Client IP and Protocol respectively. Defaults to Default.
                    # disable_outbound_snat          = false              # (Optional) Should outbound SNAT be disabled for this Load Balancer Rule? Defaults to false.
                    # enable_tcp_reset               = true               # (Optional) Is TCP Reset enabled for this Load Balancer Rule
                    }
                }
                }

   
            as={
                    platform_fault_domain_count  = 1
                    platform_update_domain_count = 1
                    #proximity_placement_group_id = 1
                    platform_managed             = true
            }
        
    }
}