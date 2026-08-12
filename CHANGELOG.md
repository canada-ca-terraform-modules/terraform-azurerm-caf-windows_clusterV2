# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.0] - 2026-08-12

### Changed

- Upgraded `azurerm` provider requirement to `~> 5.0` (pinned/tested against `5.0.1`, the target version requested for this upgrade). Created `providers.tf` — none existed before.
- Pinned the previously-unpinned `load_balancer` child module ref to `v2.0.0` (was floating on the default branch).
- Pinned the previously-unpinned `windows_VMs` (`terraform-azurerm-caf-windows_virtual_machineV2`) child module ref to `v1.2.0` (was floating on the default branch).
- Bumped the self-referential `ESLZ/SRV-windows-cluster.tf` module source ref from unpinned to `v2.0.0`.
- Bumped GitHub Actions pins: `actions/checkout` v4.1.7 → v7.0.1, `terraform-docs/gh-actions` v1.2.0 → v1.4.1 (in `documentation.yml`); added pinned `hashicorp/setup-terraform` v4.0.1 and `terraform-linters/setup-tflint` v6.3.0 (`tflint_version: v0.64.0`) in the new `terraform-ci.yml`.

### Fixed

- `loadbalancer.tf`: removed `group`, `project`, `custom_data`, `user_data` arguments from the `load_balancer` module call — these were removed as unsupported arguments in `load_balancer` v2.0.0 (dead pass-through, never consumed by that module). Passing them with the pinned `v2.0.0` ref would fail `terraform plan` with `Error: Unsupported argument`.

### Added

- `providers.tf`, `.tflint.hcl`, `.gitignore`, `.gitattributes` (none previously existed).
- `.github/workflows/terraform-ci.yml` running fmt/init/validate/test/tflint on every PR.
- `.github/workflows/release.yml` creating a GitHub release on merge to `main`, tagged from the version pinned in `ESLZ/SRV-windows-cluster.tf`.
- `tests/availability_set.tftest.hcl`, `tests/network_interface_backend_address_pool_association.tftest.hcl`, and `tests/upgrade_compat.tftest.hcl` (no prior test coverage existed).
- `sensitive = true` on all three module outputs (`VMs`, `availability_set`, `loaddbalancer`), since each exposes a full resource/module object.
- Optional name override for the availability set: `as.name` (falls back to the existing generated name formula when omitted).
- `ESLZ/SRV-windows-cluster.tfvars`: documented the optional name-override arguments introduced upstream by the newly-pinned child module versions, none of which were previously documented in this module's own examples even though both child modules already supported them:
  - `windows_virtual_machineV2` (v1.1.0+): `vm_name`, `nsg_name`, `kv_secret_name`, `os_disk.name`, `data_disks.<key>.name`, `nic.<key>.name`, `nic.<key>.ip_configuration_name`.
  - `load_balancer` (v2.0.0): `lb.frontend_ip_configuration.<key>.name`, `lb.backend_address_pool_name`, `lb.probes.<key>.name`, `lb.rules.<key>.name`.
  - Added `tests/child_module_name_overrides.tftest.hcl` asserting each of the above passes through this module's wiring to the corresponding child module output.

### Removed

- Dead local `lb-name` in `name.tf` — computed but never referenced by any resource in this module.

### Notes

- This is a major release because it raises the minimum supported stack to Terraform `>= 1.9` and `azurerm ~> 5.0`; consumers pinned to older Terraform or `azurerm` 4.x must upgrade before adopting `v2.0.0`.
- `azurerm_availability_set` and `azurerm_network_interface_backend_address_pool_association` (the only two resources owned directly by this module) have zero breaking schema changes between `azurerm` `~> 4.0` and `5.0.1` per the [azurerm 5.0 upgrade guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/5.0-upgrade-guide) — this upgrade is otherwise pure housekeeping plus the child-module-pin compatibility fix above.
- Existing `ESLZ/SRV-windows-cluster.tfvars` requires no changes — full backward compatibility preserved. The `lb.tunnel_interface` (singular) key was already used correctly in the example tfvars, matching the `load_balancer` v2.0.0 schema.

### Known blockers

- None. The user-requested target version `5.0.1` is a real published release and was installed and tested as-is.
