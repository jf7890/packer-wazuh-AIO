proxmox_url      = "https://10.10.100.1:8006/api2/json"
proxmox_username = "root@pam!packer"
proxmox_token    = "28786dd2-1eed-44e6-b8a4-dc2221ce384d"
proxmox_node     = "homelab"

iso_storage_pool = "hdd-data"
vm_storage_pool  = "local-lvm"
vm_bridge        = "vmbr10"

# sizing (optional overrides)
vm_cores     = 4
vm_memory    = 8192
vm_disk_size = "40G"
disk_layout  = "hdd-lvm"

# SSH key auth (REQUIRED for packer to connect)
ssh_private_key_file = "~/.ssh/id_ed25519"