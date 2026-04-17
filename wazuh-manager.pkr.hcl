packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.2.0"
    }
  }
}

locals {
  template_name = "${var.template_prefix}-${var.hostname}"
}

# ==========================================================
# Proxmox Builder: Ubuntu 24.04 + Wazuh all-in-one stack
# - net0: mgmt (vmbr10) used ONLY for Packer provisioning
# - net1: blue (blue)  kept for the final template
# ==========================================================
source "proxmox-iso" "wazuh_stack" {
  # ===== Proxmox connection =====
  proxmox_url      = var.proxmox_url
  username         = var.proxmox_username
  token            = var.proxmox_token
  node             = var.proxmox_node
  insecure_skip_tls_verify = var.proxmox_insecure_skip_tls_verify

  # NOTE: var.vm_id default = 0 (auto). If your plugin treats 0 as "set", change to a real ID.
  vm_id = var.vm_id

  # ===== Template identity =====
  vm_name              = local.template_name
  template_name        = local.template_name
  template_description = "Ubuntu 24.04 + Wazuh all-in-one. Build uses net0(mgmt) then post-step keeps only blue NIC."

  # ===== VM sizing =====
  cores  = var.cpu_cores
  memory = var.memory_mb

  # ===== Boot ISO (downloaded by Proxmox from the upstream URL) =====
  boot_iso {
    type             = "scsi"
    iso_url          = var.iso_url
    iso_checksum     = var.iso_checksum
    iso_storage_pool = var.iso_storage_pool
    iso_download_pve = true
    unmount          = true
  }

  # ===== Disk =====
  scsi_controller = "virtio-scsi-pci"
  disks {
    type         = "scsi"
    disk_size    = var.disk_size
    storage_pool = var.disk_storage_pool
    format       = "raw"
  }

  # net0: mgmt
  network_adapters {
    model  = "virtio"
    bridge = var.mgmt_bridge
    vlan_tag = 99
  }

  # ===== Autoinstall seed served by Packer HTTP server =====
  http_content = {
    "/user-data" = templatefile("${path.root}/http/user-data.tpl", {
      hostname             = var.hostname
      ssh_public_key       = var.ssh_public_key
      ubuntu_password_hash = var.ubuntu_password_hash
    })
    "/meta-data" = templatefile("${path.root}/http/meta-data.tpl", {
      hostname = var.hostname
    })
  }

  http_bind_address = "0.0.0.0"
  http_port_min     = 8902
  http_port_max     = 8902

  # ===== QEMU guest agent for IP discovery =====
  qemu_agent = true

  # ===== SSH =====
  ssh_username         = var.ssh_username
  ssh_password         = "ubuntu"
  ssh_private_key_file = var.ssh_private_key_file != "" ? var.ssh_private_key_file : null
  ssh_timeout          = "2h"

  # plugin reads the IP address for this interface from qemu-guest-agent
  vm_interface         = var.vm_interface

  # ===== Ubuntu autoinstall boot command =====
  boot_wait = "5s"
  boot      = "c"
  boot_key_interval = "50ms"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz ip=dhcp autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ cloud-config-url=/dev/null ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  # ===== Proxmox Cloud-Init drive (kept for clones; optional) =====
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage_pool
}
