
variable "dns_zone_name" {
  type        = string
  description = "Name of your zone in Cloud DNS"
  default     = "gke-zone"
}

variable "ingress_ip" {
  type        = string
  description = "IP address our domain name points to"
}

variable "ingress_cert_map_name" {
  type        = string
  description = "Certificate map name"
}