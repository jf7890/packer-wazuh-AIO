build {
  name    = "wazuh-stack-ubuntu2204"
  sources = ["source.proxmox-iso.wazuh_stack"]

  provisioner "file" {
    source      = "${path.root}/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["mkdir -p /tmp/wazuh-scripts"]
  }

  provisioner "file" {
    source      = "${path.root}/scripts/"
    destination = "/tmp/wazuh-scripts/"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/wazuh-scripts/provision-wazuh-manager.sh",
      "cd /tmp/wazuh-scripts && sudo -n -E bash ./provision-wazuh-manager.sh"
    ]
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}
