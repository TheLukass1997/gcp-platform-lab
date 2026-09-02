resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/24"]
}

resource "google_compute_firewall" "allow_node_exporter" {
  name    = "allow-node-exporter"
  project = var.project_id
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_ranges = ["10.10.0.0/24"]
}