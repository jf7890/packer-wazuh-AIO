# ===== Identity =====
variable "template_prefix" {
  type    = string
  default = "tpl"
}

variable "hostname" {
  type    = string
  default = "wazuh-stack"
}

# ===== VM sizing =====
variable "cpu_cores" {
  type    = number
  default = 4
}

variable "memory_mb" {
  type    = number
  default = 16384
}

variable "disk_storage_pool" {
  type    = string
  default = "hdd-lvm"
}

variable "disk_size" {
  type    = string
  default = "40G"
}

# ===== Storage / Network =====
variable "iso_storage_pool" {
  type    = string
  default = env("PACKER_ISO_STORAGE")
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/releases/24.04.3/ubuntu-24.04.3-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
}

variable "mgmt_bridge" {
  type    = string
  default = env("PACKER_BRIDGE_LAN")
}

variable "cloud_init_storage_pool" {
  type    = string
  default = "local-lvm"
}

# ===== SSH key-based =====
variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_key" {
  type    = string
  default = env("PACKER_SSH_PUBLIC_KEY")
}

variable "ssh_private_key_file" {
  type    = string
  default = env("PACKER_SSH_PRIVATE_KEY")
}

variable "ssh_host" {
  type    = string
  default = env("PACKER_SSH_HOST")
}

variable "vm_interface" {
  type    = string
  default = "ens18"
}

# ===== Proxmox connection =====
variable "proxmox_url" {
  type    = string
  default = env("PROXMOX_URL")
}

variable "proxmox_username" {
  type    = string
  default = env("PROXMOX_USERNAME")
}

variable "proxmox_token" {
  type      = string
  sensitive = true
  default   = env("PROXMOX_TOKEN")
}

variable "proxmox_node" {
  type    = string
  default = env("PROXMOX_NODE")
}

variable "proxmox_insecure_skip_tls_verify" {
  type    = bool
  default = true
}

# NOTE: 0 is what you provided; behavior depends on plugin implementation.
variable "vm_id" {
  type    = number
  default = 0
}

# Autoinstall requires a non-root user + password hash (SSH password login is disabled).
variable "ubuntu_password_hash" {
  type = string
}
