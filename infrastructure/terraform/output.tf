// Master

output "kubernetes_cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE Cluster Host"
}