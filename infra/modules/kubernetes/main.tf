
locals {
  envname = terraform.workspace
}

# Access the configuration of the provider
data "google_client_config" "current" {}

#+-------------------------------------
#| CLUSTER
#+-------------------------------------

# Create a GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = coalesce(var.cluster_location, "${data.google_client_config.current.region}-a")

  # To be able to clean up
  deletion_protection = false

  # Ignore changes to min-master-version as that gets changed
  # after deployment to minimum precise version Google has
  lifecycle {
    ignore_changes = [
      min_master_version,
    ]
  }

  # Timeout after 45 min if creation is still pending
  timeouts {
    create = "45m"
    update = "60m"
  }

  # Nodes
  initial_node_count = var.cluster_node_count

  node_config {
    # https://cloud.google.com/compute/docs/general-purpose-machines
    machine_type = var.node_machine_type

    # https://cloud.google.com/compute/docs/disks#disk-types
    disk_type    = var.node_disk_type
    disk_size_gb = var.node_disk_size_gb

    # https://cloud.google.com/compute/docs/access/service-accounts#default_scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    labels = {
      env = local.envname
    }
    # Tags represent firewall rules applied to each node
    tags = [
      "gke-node",
      "gke-${local.envname}-node",
    ]
  }

  # Add the gateway CRD
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
}

# Will help generate the kubeconfig file (see outputs)
#module "primary_auth" {
#  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#  version      = "24.1.0"#

#  project_id   = google_container_cluster.primary.project
#  location     = google_container_cluster.primary.location
#  cluster_name = google_container_cluster.primary.name
#}

#+-------------------------------------
#| FIREWALL
#+-------------------------------------

# Add firewall rules
resource "google_compute_firewall" "nodeports" {
  name    = "${var.cluster_name}-nodeports-range"
  network = "default"

  # ports 30000-32767 for potential kubernetes node ports
  # port 80 for HTTP and 443 for HTTPS
  # port 22 for SSH into the node and pod if needed
  allow {
    protocol = "tcp"
    ports    = ["30000-32767", "80", "443", "8080", "22"]
  }
  # ping any node
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

#+-------------------------------------
#| INGRESS SETTINGS
#+-------------------------------------

# Reserve a static external IP address
resource "google_compute_global_address" "gke_ingress_ipv4" {
  name          = "${var.cluster_name}-ingress-global-ipv4"
  ip_version    = "IPV4"
  address_type  = "EXTERNAL"
}

#resource "google_compute_address" "gke_ingress_ipv4" {
#  name         = "gke-ingress-regional-ipv4"
#  ip_version   = "IPV4"
#  address_type = "EXTERNAL"
#}

# Create a certificate map (our DNS module will add SSL certificate / hostname associations)
# > gcloud certificate-manager maps create demo-example-com-map
resource "google_certificate_manager_certificate_map" "gke_ingress_certificate_map" {
  name   = "${var.cluster_name}-ingress-map-entry"

  labels = {
    terraform = true
  }
}
