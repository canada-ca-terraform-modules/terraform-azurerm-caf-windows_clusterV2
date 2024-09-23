variable "windows_vms_clusterV2" {
  type = any
  default = {}
  description = "Value for windows cluster V2. This is a collection of values as defined in SRV-windows-cluster.tfvars"
}

module "windows_VMs_clusterV2" {

    for_each = var.windows_vms_clusterV2
    source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-vmss-windowsV2.git"
    location= var.location
    env = var.env
    group = var.group
    project = var.project
    userDefinedString = each.value.userDefinedString
    windows_vms_cluster = each.value
    resource_groups = local.resource_groups_all
    subnets = local.subnets
    user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
}