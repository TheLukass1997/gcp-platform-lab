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

module "firewall" {
  source = "../../modules/firewall"

  project_id   = var.project_id
  network_name = module.network.network_name
}

module "compute" {
  source = "../../modules/compute"

  project_id = var.project_id

  zone = "europe-central2-a"

  instance_name = "platform-admin-01"

  machine_type = "e2-medium"

  subnetwork = module.network.subnet_name

  service_account_email = module.service_accounts.vm_sa_email
}

#oidc module for github actions TEST
module "oidc" {
  source = "../../modules/oidc"

  project_id     = var.project_id
  project_number = "20594777344"

  github_repository = "TheLukass1997/gcp-platform-lab"

  terraform_sa_email = module.service_accounts.terraform_sa_email
}