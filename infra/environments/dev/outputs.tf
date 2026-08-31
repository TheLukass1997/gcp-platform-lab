output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "network_name" {
  value = module.network.network_name
}

output "subnet_name" {
  value = module.network.subnet_name
}

output "router_name" {
  value = module.nat.router_name
}

output "firewall_ssh_rule" {
  value = module.firewall.ssh_rule
}

output "instance_name" {
  value = module.compute.instance_name
}

output "private_ip" {
  value = module.compute.private_ip
}