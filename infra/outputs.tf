output "vm_external_ip" {
  description = "Kittygram VM public IP"
  value       = yandex_vpc_address.infra_address.external_ipv4_address[0].address
}

output "kittygram_url" {
  description = "Kittygram public URL"
  value       = "http://${yandex_vpc_address.infra_address.external_ipv4_address[0].address}:${var.gateway_port}"
}

output "ssh_command" {
  description = "SSH command for the deploy user"
  value       = "ssh ${var.ssh_user}@${yandex_vpc_address.infra_address.external_ipv4_address[0].address}"
}
