
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

# IP
output "kubernetes_ingress_ipv4_name" {
  value       = "${google_compute_address.gke_ingress_ipv4.name}"
  sensitive   = false
}

output "kubernetes_ingress_ipv4_address" {
  value       = "${google_compute_address.gke_ingress_ipv4.address}"
  sensitive   = false
}