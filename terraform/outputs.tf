output "endpoint" {
  value = google_container_cluster.default.endpoint
}

output "master_version" {
  value = google_container_cluster.default.master_version
}

output "region" {
  value = var.location
}

output "kubernetes_cluster_name" {
  value = var.name
}