resource "google_compute_instance" "platform" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    # brak access_config
    # brak publicznego IP
  }

  service_account {
    email = var.service_account_email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  tags = [
    "ssh",
    "monitoring"
  ]
}