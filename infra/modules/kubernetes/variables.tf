
# Cluster settings
variable "cluster_name" {
  type        = string
  description = "Cluster ID"
  default     = "test-gke"
}

variable "cluster_location" {
  type        = string
  description = "Cluster zone / region (us-west1-a / us-west1). If blank: region > zone A of the current provider"
  default     = "" # if blank: first zone of the current provider location
}

variable "cluster_node_count" {
  type        = number
  description = "Cluster's initial node count"
  default     = 2
}

# Nodes settings
variable "node_machine_type" {
  type        = string
  description = "Nodes: Machine type"
  default     = "n1-standard-1"
}

variable "node_disk_type" {
  type        = string
  description = "Nodes: Disk type"
  default     = "pd-standard"
}

variable "node_disk_size_gb" {
  type        = number
  description = "Nodes: Disk size (in GB)"
  default     = 10
}

# Static IP
#variable "static_ip_name" {
#  type        = string
#  default     = "ingress-static-ip"
#}