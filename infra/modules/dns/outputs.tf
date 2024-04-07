
output "hostname" {
  description = "DNS hostname — ie example-domain.com"
  value       = local.hostname
  sensitive   = false
}