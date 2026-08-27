resource "google_project_service" "required_services" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com"
  ])

  service = each.value

  disable_on_destroy = false
}

module "service_accounts" {
  source = "../../modules/service_accounts"
}