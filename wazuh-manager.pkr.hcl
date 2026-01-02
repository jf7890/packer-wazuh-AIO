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

source "proxmox-iso" "wazuh_manager" {
  # Proxmox connection
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.proxmox_node
  insecure_skip_tls_verify = var.proxmox_insecure

  # VM / Template
  vm_name               = local.template_name
  template_description  = "Wazuh Manager template (Ubuntu 24.04) - built by Packer"
  tags                  = var.template_tags
  os                    = "l26"
  qemu_agent            = true

  # ISO (PVE downloads ISO to avoid upload issues)
  boot_iso {
    type             = "scsi"
    iso_url          = var.iso_url
    iso_checksum     = var.iso_checksum
    iso_storage_pool = var.iso_storage_pool
    iso_download_pve = true
    unmount          = true
  }

  # Sizing (defaults: 4c / 8G / 40G)
  cores     = var.vm_cores
  memory    = var.vm_memory
  disk_size = var.vm_disk_size
  disk_type = "scsi"
  scsi_controller = "virtio-scsi-pci"
  storage_pool    = var.vm_storage_pool

  network_adapters {
    bridge = var.vm_bridge
    model  = "virtio"
  }

  # Autoinstall via NoCloud over HTTP
  http_directory = "${path.root}/http/${var.disk_layout}"

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  # SSH communicator (key-based)
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = var.ssh_timeout
}

build {
  name    = "wazuh-manager-template"
  sources = ["source.proxmox-iso.wazuh_manager"]

  # Upload configs
  provisioner "file" {
    source      = "${path.root}/files/ossec.conf"
    destination = "/tmp/ossec.conf"
  }

  provisioner "file" {
    source      = "${path.root}/files/local_rules.xml"
    destination = "/tmp/local_rules.xml"
  }

  provisioner "file" {
    source      = "${path.root}/files/filebeat.yml"
    destination = "/tmp/filebeat.yml"
  }

  # Install Wazuh manager + config (silent services)
  provisioner "shell" {
    script = "${path.root}/scripts/provision-wazuh-manager.sh"
  }
}
