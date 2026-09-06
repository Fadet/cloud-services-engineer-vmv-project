variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "infra-network"
}

variable "net_cidr" {
  description = "Subnet structure"
  type = list(object({
    name   = string,
    zone   = string,
    prefix = string
  }))

  default = [
    { name = "infra-subnet-a", zone = "ru-central1-a", prefix = "10.129.1.0/24" },
    { name = "infra-subnet-b", zone = "ru-central1-b", prefix = "10.130.1.0/24" },
    { name = "infra-subnet-d", zone = "ru-central1-d", prefix = "10.131.1.0/24" },
  ]
}

variable "image_family" {
  description = "VM image family"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "ssh_user" {
  description = "VM user for deploys"
  type        = string
  default     = "kittygram"
}

variable "ssh_public_key" {
  description = "SSH public key for the VM user"
  type        = string
  sensitive   = true
}

variable "gateway_port" {
  description = "Public gateway port"
  type        = number
  default     = 9000
}

variable "vm_cores" {
  description = "VM CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "VM memory in GB"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "VM boot disk size in GB"
  type        = number
  default     = 20
}

variable "vm_disk_type" {
  description = "VM boot disk type"
  type        = string
  default     = "network-ssd"
}