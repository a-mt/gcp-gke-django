
# Instance settings
variable "instance_name" {
  type        = string
  description = "Instance name"
  default     = "django-postgres"
}

variable "instance_version" {
  type        = string
  description = "Instance version"
  default     = "POSTGRES_15"
}

variable "instance_size" {
  type        = string
  description = "Instance tier settings"
  default     = "db-f1-micro"
}

# Database settings
variable "database_name" {
  type        = string
  description = "Database name"
  default     = "postgres-db"
}

variable "database_username" {
  type        = string
  description = "Database user name"
  default     = "postgres-user"
}

variable "database_password" {
  type        = string
  description = "Database user password"
  default     = "postgres-password"
}
