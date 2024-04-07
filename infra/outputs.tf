
#+-------------------------------------
#| CLOUDSQL
#+-------------------------------------

# Connection
output "postgres_connection_name" {
  value     = module.postgres.postgres_connection_name
  sensitive = true
}
output "postgres_connection_json_key" {
  value     = module.postgres.postgres_connection_json_key
  sensitive = true
}

# Database
output "postgres_database_name" {
  value     = module.postgres.postgres_database_name
  sensitive = true
}
output "postgres_database_user" {
  value     = module.postgres.postgres_database_user
  sensitive = true
}
output "postgres_database_password" {
  value     = module.postgres.postgres_database_password
  sensitive = true
}
output "postgres_env_vars" {
  value = <<-EOT
  DATABASE_NAME=${module.postgres.postgres_database_name}
  DATABASE_USERNAME=${module.postgres.postgres_database_user}
  DATABASE_PASSWORD=${module.postgres.postgres_database_password}
  DATABASE_CONNECTION_NAME=${module.postgres.postgres_connection_name}
  EOT
  sensitive = true
}

#+-------------------------------------
#| KUBERNETES
#+-------------------------------------

# Connection
output "kubernetes_kubeconfig" {
  value     = module.kubernetes.kubernetes_kubeconfig
  sensitive = true
}

# Utils
output "kubernetes_cluster_name" {
  value     = module.kubernetes.kubernetes_cluster_name
  sensitive = false
}
output "kubernetes_cluster_ip" {
  value     = module.kubernetes.kubernetes_cluster_ip
  sensitive = false
}

output "kubernetes_ingress_ipv4_name" {
  value     = module.kubernetes.kubernetes_ingress_ipv4_name
  sensitive = false
}

output "kubernetes_ingress_ipv4_address" {
  value     = module.kubernetes.kubernetes_ingress_ipv4_address
  sensitive = false
}

#+-------------------------------------
#| DNS
#+-------------------------------------

output "dns_hostname" {
  value     = module.dns.hostname
  sensitive = false
}

#+-------------------------------------
#| DOCKER REGISTRY
#+-------------------------------------

# Credentials
output "docker_registry_write_json_key" {
  value     = module.docker_registry.docker_registry_write_json_key
  sensitive = true
}

# Repository
output "docker_registry_hostname" {
  value     = module.docker_registry.docker_registry_hostname
  sensitive = false
}
output "docker_registry_repository_url" {
  value     = module.docker_registry.docker_registry_repository_url
  sensitive = false
}