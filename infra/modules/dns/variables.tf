
variable "zone_name" {
  type        = string
  description = "Name of your zone in Cloud DNS"
  default     = "gke-zone"
}

variable "target_ip" {
  type        = string
  description = "IP address our domain name points to"
}