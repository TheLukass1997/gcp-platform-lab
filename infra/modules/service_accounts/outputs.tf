output "terraform_sa_email" {
  value = google_service_account.terraform.email
}

output "vm_sa_email" {
  value = google_service_account.vm.email
}