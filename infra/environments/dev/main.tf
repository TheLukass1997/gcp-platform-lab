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

module "network" {
  source = "../../modules/network"

  project_id = var.project_id
  region     = var.region

  vpc_name    = "platform-vpc"
  subnet_name = "platform-subnet"

  subnet_cidr = "10.10.0.0/24"
}

module "nat" {
  source = "../../modules/nat"

  project_id = var.project_id
  region     = var.region

  network_id = module.network.network_id

  router_name = "platform-router"
}