resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "cluster" {
  name     = "${var.project_name}-cluster"
  location = var.location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 2
  network = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnetwork.id
  resource_labels = var.labels
  networking_mode = "VPC_NATIVE"

  release_channel {
    channel = var.gke_release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = google_compute_subnetwork.subnetwork.secondary_ip_range.1.range_name
  }

}

resource "google_container_node_pool" "main_node_pool" {
  name       = "${var.project_name}-main-pool"
  location   = var.location
  cluster    = google_container_cluster.cluster.name
  initial_node_count = 1
  
  
  node_config {
    preemptible  = false
    machine_type = "e2-standard-2"
    disk_size_gb = 10

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "node_pool" {
  name       = "${var.project_name}-pool-b"
  location   = var.location
  cluster    = google_container_cluster.cluster.name
  initial_node_count = 0
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }
  
  
  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 10

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}