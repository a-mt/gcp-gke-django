
output "root_domain" {
  description = "DNS hostname — ie example-domain.com"
  value       = local.root_domain
  sensitive   = false
}

output "dns_domains" {
  description = "Created A record hostnames — ie api.example-domain.com."
  value       = local.dns_domains
  sensitive   = false
}
