
output "postgres_env_vars" {
  value = <<-EOT
  DATABASE_NAME=${module.postgres.postgres_database_name}
  DATABASE_USERNAME=${module.postgres.postgres_database_user}
  DATABASE_PASSWORD=${module.postgres.postgres_database_password}
  DATABASE_CONNECTION_NAME=${module.postgres.postgres_connection_name}
  EOT
  sensitive = true
}

output "cicd_docker_credentials" {
  value = <<-EOT
  DOCKER_REGISTRY='${module.docker_registry.docker_registry_hostname}';
  DOCKER_REPOSITORY='${module.docker_registry.docker_registry_repository}';
  DOCKER_CREDENTIALS='${replace(base64decode(module.docker_registry.docker_registry_write_json_key), "\n", "")}';
  echo "$DOCKER_CREDENTIALS" | docker login -u _json_key --password-stdin https://$DOCKER_REGISTRY
  EOT
  sensitive = true
}

output "kubernetes_kubeconfig" {
  value       = module.kubernetes.kubernetes_kubeconfig
  sensitive   = true
  description = "Gives us Terraform's access token, lasts 1h"
}

output "helm_values" {
  value = <<-EOT
  loadBalancerGlobalIPAddress: ${module.kubernetes.kubernetes_ingress_global_ipv4_address}
  loadBalancerGlobalIPName: ${module.kubernetes.kubernetes_ingress_global_ipv4_name}
  loadBalancerRootDomain: ${module.dns.root_domain}
  loadBalancerManagedCerticateMap: ${module.kubernetes.kubernetes_ingress_certificate_map_name}
  databaseConnectionName: ${module.postgres.postgres_connection_name}
  image: ${module.docker_registry.docker_registry_hostname}/${module.docker_registry.docker_registry_repository}/django:latest
  EOT
  sensitive = true
}

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

#+-------------------------------------
#| KUBERNETES
#+-------------------------------------

# Utils
output "kubernetes_cluster_name" {
  value     = module.kubernetes.kubernetes_cluster_name
  sensitive = false
}
output "kubernetes_cluster_ip" {
  value     = module.kubernetes.kubernetes_cluster_ip
  sensitive = false
}
output "kubernetes_cluster_ca_certificate" {
  value     = module.kubernetes.kubernetes_cluster_ca_certificate
  sensitive = true
}

# Ingress/gateway settings
output "ingress_global_ipv4_name" {
  value     = module.kubernetes.kubernetes_ingress_global_ipv4_name
  sensitive = false
}

output "ingress_global_ipv4_address" {
  value     = module.kubernetes.kubernetes_ingress_global_ipv4_address
  sensitive = false
}

output "ingress_certificate_map_name" {
  value     = module.kubernetes.kubernetes_ingress_certificate_map_name
  sensitive = false
}

#+-------------------------------------
#| DNS
#+-------------------------------------

output "dns_root_domain" {
  value     = module.dns.root_domain
  sensitive = false
}

output "dns_domains" {
  value     = module.dns.dns_domains
  sensitive = false
}

#+-------------------------------------
#| DOCKER REGISTRY
#+-------------------------------------

# Credentials
# GOOGLE_APPLICATION_CREDENTIALS=$(echo $DOCKER_AUTH | base64 -d | tr -s '\n' ' ')
output "docker_registry_write_json_key" {
  value     = module.docker_registry.docker_registry_write_json_key
  sensitive = true
}

# Repository
output "docker_registry_hostname" {
  value     = module.docker_registry.docker_registry_hostname
  sensitive = false
}
output "docker_registry_repository" {
  value     = module.docker_registry.docker_registry_repository
  sensitive = false
}
