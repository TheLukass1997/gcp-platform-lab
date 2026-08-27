resource "google_service_account" "terraform" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
}

resource "google_service_account" "vm" {
  account_id   = "vm-platform-sa"
  display_name = "Platform VM Service Account"
}