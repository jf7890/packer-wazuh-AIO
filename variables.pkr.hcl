variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL, e.g. https://pve:8006/api2/json"
}
variable "proxmox_username" {
  type        = string
  description = "Proxmox username, including realm. If using API token auth, include token id like user@pam!tokenid"
}
variable "proxmox_token" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}
variable "proxmox_node" {
  type        = string
  description = "Target Proxmox node name"
}
variable "proxmox_insecure" {
  type        = bool
  default     = true
  description = "Skip TLS verification (dev/lab only)"
}

variable "template_prefix" {
  type        = string
  default     = "cr"
  description = "Prefix for template name"
}
variable "hostname" {
  type        = string
  default     = "wazuh-manager"
  description = "Hostname inside the VM and template name suffix"
}
variable "template_tags" {
  type        = string
  default     = "cyber-range,wazuh"
  description = "Proxmox tags"
}

# ISO settings (Ubuntu 24.04.3 live-server)
variable "iso_url" {
  type        = string
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
}
variable "iso_checksum" {
  type        = string
  default     = "file:https://releases.ubuntu.com/noble/SHA256SUMS"
  description = "Checksum file URL (Packer will look up the ISO hash inside)"
}
variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool that holds ISO images (e.g. local)"
}

# VM sizing defaults
variable "vm_cores" {
  type        = number
  default     = 4
}
variable "vm_memory" {
  type        = number
  default     = 8192
  description = "Memory in MB"
}
variable "vm_disk_size" {
  type        = string
  default     = "40G"
}
variable "vm_storage_pool" {
  type        = string
  description = "Proxmox storage pool for VM disks (e.g. local-lvm, ceph, ...)"
}
variable "vm_bridge" {
  type        = string
  default     = "vmbr10"
}

# Partition/layout selector (maps to Ubuntu autoinstall 'storage.layout.name')
variable "disk_layout" {
  type        = string
  default     = "hdd-lvm"
  description = "Choose: hdd-lvm or hdd-direct"
  validation {
    condition     = contains(["hdd-lvm", "hdd-direct"], var.disk_layout)
    error_message = "disk_layout must be one of: hdd-lvm, hdd-direct"
  }
}

# SSH
variable "ssh_username" {
  type        = string
  default     = "blue"
}
variable "ssh_private_key_file" {
  type        = string
  description = "Path to your SSH private key file (ed25519). Do NOT commit private keys."
}
variable "ssh_timeout" {
  type        = string
  default     = "30m"
}
