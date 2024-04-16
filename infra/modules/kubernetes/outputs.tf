
output "kubernetes_kubeconfig" {
  value = templatefile("${path.module}/templates/kubeconfig-template.yaml.tpl", {
    context                = google_container_cluster.primary.name
    endpoint               = google_container_cluster.primary.endpoint
    cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
    token                  = data.google_client_config.current.access_token
  })
  description = "Credentials to connect to the cluster"
  sensitive   = true
}

#output "kubernetes_kubeconfig" {
#  value       = module.primary_auth.kubeconfig_raw
#  description = "Credentials to connect to the cluster"
#  sensitive   = true
#}

# You can find it as "clusters.0.name" in the kubeconfig
output "kubernetes_cluster_name" {
  value       = "${google_container_cluster.primary.name}"
  sensitive   = false
}

# You can find it as "clusters.0.cluster.server" in the kubeconfig
output "kubernetes_cluster_ip" {
  value       = "${google_container_cluster.primary.endpoint}"
  sensitive   = false
}

output "kubernetes_cluster_ca_certificate" {
  value       = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive   = true
}

output "kubernetes_temporary_access_token" {
  value       = data.google_client_config.current.access_token
  sensitive   = true
  description = "1H token"
}

# IP
#output "kubernetes_ingress_regional_ipv4_name" {
#  value       = "${google_compute_address.gke_ingress_ipv4.name}"
#  sensitive   = false
#}
#
#output "kubernetes_ingress_regional_ipv4_address" {
#  value       = "${google_compute_address.gke_ingress_ipv4.address}"
#  sensitive   = false
#}

output "kubernetes_ingress_global_ipv4_name" {
  description = "Static IP name"
  value       = "${google_compute_global_address.gke_ingress_ipv4.name}"
  sensitive   = false
}

output "kubernetes_ingress_global_ipv4_address" {
  description = "Static IP address"
  value       = "${google_compute_global_address.gke_ingress_ipv4.address}"
  sensitive   = false
}

output "kubernetes_ingress_certificate_map_name" {
  description = "Certificate map name (in Google Certificate Manager)"
  value       = google_certificate_manager_certificate_map.gke_ingress_certificate_map.name
  sensitive   = false
}
