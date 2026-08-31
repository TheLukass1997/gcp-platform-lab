output "instance_name" {
  value = google_compute_instance.platform.name
}

output "private_ip" {
  value = google_compute_instance.platform.network_interface[0].network_ip
}