
# Retrieve our DNS zone data
data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}

locals {
  zone_name     = data.google_dns_managed_zone.dns_zone.name
  zone_dns_name = data.google_dns_managed_zone.dns_zone.dns_name
  ip_to_label   = replace(var.ingress_ip, ".", "_")

  root_domain = trimsuffix(local.zone_dns_name, ".")
  dns_domains = toset([
    "api.${local.zone_dns_name}",
  ])
}

# Create a A record in our DNS zone
# to link the domain name to our GKE endpoint
resource "google_dns_record_set" "main" {
  for_each     = local.dns_domains
  name         = each.key

  type         = "A"
  ttl          = 300
  rrdatas      = [var.ingress_ip]
  managed_zone = local.zone_name
}

#+-------------------------------------
#| SSL CERTIFICATE MANAGER
#| https://cloud.google.com/certificate-manager/docs/overview
#| https://cloud.google.com/kubernetes-engine/docs/concepts/gateway-api#ingress
#| https://medium.com/google-cloud/certificate-management-for-gke-gateway-with-certificate-manager-85af65f68103
#+-------------------------------------

# Create a DNS challenge
resource "google_certificate_manager_dns_authorization" "main_auth" {
  name        = "${local.zone_name}-dnsauth"
  domain      = local.root_domain

  # Recreate a new DNS challenge if the IP address changed
  labels = {
    terraform = true
    ingress-ip = local.ip_to_label
  }
}

# Resolve the DNS challenge
resource "google_dns_record_set" "cname" {
  type         = google_certificate_manager_dns_authorization.main_auth.dns_resource_record[0].type
  name         = google_certificate_manager_dns_authorization.main_auth.dns_resource_record[0].name
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.main_auth.dns_resource_record[0].data]
  managed_zone = local.zone_name
}

# Create a certificate / private key
resource "google_certificate_manager_certificate" "tls" {
  name        = "${local.zone_name}-rootcert"
  scope       = "DEFAULT"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.main_auth.domain,
      "*.${google_certificate_manager_dns_authorization.main_auth.domain}",
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.main_auth.id,
    ]
  }
  labels = {
    terraform = true
    ingress-ip = local.ip_to_label
  }
}

#+-------------------------------------
#| SSL CERTIFICATE MAP
#+-------------------------------------

# Add a certificate / hostname entry
# > gcloud certificate-manager maps entries create demo-example-com-map-entry \
# > --map=demo-example-com-map \
# > --hostname=demo.example.com \
# > --certificates=demo-example-com-cert
resource "google_certificate_manager_certificate_map_entry" "default" {
  name         = "${local.zone_name}-certmap-entry"
  map          = var.ingress_cert_map_name

  matcher      = "PRIMARY"
  certificates = [google_certificate_manager_certificate.tls.id]

  labels      = {
    terraform = true
    ingress-ip = local.ip_to_label
  }
}
