output "vm_external_ip" {
  description = "Kittygram VM public IP"
  value       = yandex_compute_instance.vm_1.network_interface[0].nat_ip_address
}

output "kittygram_url" {
  description = "Kittygram public URL"
  value       = "http://${yandex_compute_instance.vm_1.network_interface[0].nat_ip_address}:${var.gateway_port}"
}

output "ssh_command" {
  description = "SSH command for the deploy user"
  value       = "ssh ${var.ssh_user}@${yandex_compute_instance.vm_1.network_interface[0].nat_ip_address}"
}
