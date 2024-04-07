
# Retrieve our DNS zone data
data "google_dns_managed_zone" "dns_zone" {
  name = var.zone_name
}

locals {
  hostname = data.google_dns_managed_zone.dns_zone.dns_name
  domains  = toset([
    "api.${local.hostname}",
  ])
}

# Create a A record in our DNS zone
# to link the domain name to our GKE endpoint
resource "google_dns_record_set" "website" {
  for_each     = local.domains
  name         = each.key

  type         = "A"
  ttl          = 300
  rrdatas      = [var.target_ip]
  managed_zone = data.google_dns_managed_zone.dns_zone.name
}

# https://www.willianantunes.com/blog/2021/05/gke-ingress-how-to-configure-ipv4-and-ipv6-addresses/
#resource "google_compute_managed_ssl_certificate" "tls_certs" {
#  name = "gke-certs"

#  managed {
#    domains = local.domains
#  }
#}
