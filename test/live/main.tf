terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {
    resource_group {
      # This harness's resource group is fully self-owned by Terraform - no
      # risk of destroying anything not created by this run.
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "windows_VMs_clusterV2" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  # (no-op touch: triggers the live-test workflow's pull_request path filter
  # for this PR, since it otherwise only touches .github/workflows/**)
  source = "../../"

  location            = var.location
  env                 = var.env
  group               = var.group
  project             = var.project
  userDefinedString   = "livetest"
  windows_vms_cluster = var.windows_vms_cluster
  resource_groups     = local.resource_groups # from test_dependencies.tf
  subnets             = local.subnets         # from test_dependencies.tf
  tags                = var.tags
}
