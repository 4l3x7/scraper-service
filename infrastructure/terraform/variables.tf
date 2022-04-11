variable "project_name" {
  description = "GCP Project name. It needs to be already created"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the project"
  type        = map
}

variable "integration_labels" {
  description = "A set of key/value label pairs to assign to the project for integration."
  type        = map
}

variable "staging_labels" {
  description = "A set of key/value label pairs to assign to the project for staging."
  type        = map
}

variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list
}

variable "region" {
  description = "Google Cloud region, by deafult use 'europe-west1'"
  type        = string
  default     = "europe-west1"
}

variable "location" {
  description = "Google Cloud location (for GKE), by default use 'europe-west1-b'"
  type        = string
  default     = "europe-west1-b"
}

variable "node_count" {
  type        = number
  description = "GKE Cluster main pool node count"
  default = 1
}

variable "machine_type" {
  type        = string
  description = "GKE Cluster node type, for non-production 'e2-custom-4-5120'"
  default = "e2-standard-2"
}

variable "billing_account" {
  description = "Billing Account"
  type        = string
  default     = "0"
}

variable "gke_release_channel" {
  description = "GKE RELEASE CHANNEL"
  type        = string
  default     = "STABLE"
}

# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}