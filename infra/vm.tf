data "yandex_compute_image" "image" {
  family = var.image_family
} 

resource "yandex_compute_instance" "vm_1" {
  name                      = "kittygram-vm"
  hostname                  = "kittygram"
  platform_id               = "standard-v3"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      type     = var.vm_disk_type
      image_id = data.yandex_compute_image.image.id
      size     = var.vm_disk_size
    }
  }

  network_interface {
    subnet_id            = yandex_vpc_subnet.infra_subnet[0].id
    nat                  = true
    security_group_ids   = [yandex_vpc_security_group.infra_sg.id]
  }

  metadata = {
    serial-port-enable = "1"
    user-data = templatefile("${path.module}/cloud-init.yaml", 
    {
      ssh_user       = var.ssh_user
      ssh_public_key = var.ssh_public_key
    })
  }
}