output "VMs" {
  description = "The vm module object"
  value       = module.windows_VMs
}

output "availability_set" {
  description = "The availability_set object"
  value       = azurerm_availability_set.availability_set
}

output "loaddbalancer" {
  description = "The availability_set object"
  value       = module.load_balancer
}
