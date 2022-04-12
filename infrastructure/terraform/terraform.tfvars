# project_name = "" 
# project_id = "" 
# region = "europe-west1"
# location = "europe-west1-b"
node_count = 1
machine_type = "e2-standard-2"
# billing_account = ""
labels = {
  "environment" = "development"
  "requester" = "phaidra"
}
integration_labels = {
  "environment" = "integration"
}
staging_labels = {
  "environment" = "staging"
}
gke_release_channel = "STABLE"
gcp_service_list = [
  "compute.googleapis.com",               # Compute Engine API
  "iam.googleapis.com",                   # Identity and Access Management (IAM) API
  "iamcredentials.googleapis.com",        # IAM Service Account Credentials API
  "servicemanagement.googleapis.com",     # Service Management API
  "serviceusage.googleapis.com",          # Service Usage API
  "storage-api.googleapis.com",           # Google Cloud Storage JSON API
  "storage-component.googleapis.com",     # Cloud Storage
  "networkmanagement.googleapis.com",     # Network
  "cloudresourcemanager.googleapis.com",  # Cloud resources
  "cloudbilling.googleapis.com",          # Billing
  "servicenetworking.googleapis.com",     # Networking"
  "container.googleapis.com",             # GKE
]

