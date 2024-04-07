
#+-------------------------------------
#| AUTHORIZATION
#+-------------------------------------

# Credentials
variable "gcp_credentials" {
  type        = string
  description = "Credentials (JSON key content without newlines)"
}
variable "gcp_project_id" {
  type        = string
  description = "Project ID — test-django-419014"
}
variable "gcp_region" {
  type        = string
  description = "Default region to manage resources"
  default     = "us-west1"
}

# Project
variable "gcp_project_name" {
  type        = string
  description = "Project name — test-django"
}
variable "gcp_project_number" {
  type        = string
  description = "Project number — 8575900557"
}

#+-------------------------------------
#| PREFERENCES
#+-------------------------------------

variable "postgres_instance_name" {
  type    = string
  default = "django-postgres"
}
variable "postgres_database_name" {
  type    = string
  default = "postgres-db"
}
variable "postgres_database_username" {
  type    = string
  default = "postgres-user"
}
variable "postgres_database_password" {
  type    = string
  default = "postgres-password"
}

variable "kubernetes_cluster_name" {
  type    = string
  default = "test-gke"
}
variable "dns_zone_name" {
  type    = string
  default = "gke-zone"
}
variable "docker_registry_repository_name" {
  type    = string
  default = "test-gke-repo"
}
