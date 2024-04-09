
# Create a postgres database on GCP Cloud SQL (managed database)
module "postgres" {
  source            = "./modules/postgres"
  instance_name     = var.postgres_instance_name
  database_name     = var.postgres_database_name
  database_username = var.postgres_database_username
  database_password = var.postgres_database_password
}

# Create a kubernetes cluster
module "kubernetes" {
  source            = "./modules/kubernetes"
  cluster_name      = var.kubernetes_cluster_name
}

# Create a docker repository
module "docker_registry" {
  source            = "./modules/docker_registry"
  repository_name   = var.docker_registry_repository_name

  # The default compute service account has to be created first
  # before we can add read permissions to it
  depends_on        = [module.kubernetes]
}

# Create a DNS entry for our ingress
module "dns" {
  source                = "./modules/dns"
  ingress_ip            = module.kubernetes.kubernetes_ingress_global_ipv4_address
  ingress_cert_map_name = module.kubernetes.kubernetes_ingress_certificate_map_name
  dns_zone_name         = var.dns_zone_name
}
