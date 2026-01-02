# Auto-loaded vars for packer (no need to pass -var-file)
# NOTE: Replace placeholders before running `packer build`.

# --- Proxmox connection ---
proxmox_url      = "https://PVE_HOST:8006/api2/json"
proxmox_username = "root@pam"        # or: "user@pam!tokenid" if you use API token auth
proxmox_token    = "YOUR_TOKEN_SECRET" # token secret (NOT token id)
proxmox_node     = "pve"

# --- Proxmox resources ---
iso_storage_pool = "local"
vm_storage_pool  = "local-lvm"
vm_bridge        = "vmbr0"

# --- VM sizing (defaults) ---
vm_cores     = 4
vm_memory    = 8192
vm_disk_size = "40G"

# --- SSH (packer communicator) ---
# IMPORTANT: Point to the PRIVATE KEY FILE that matches the authorized public key
# embedded in autoinstall (your provided ed25519 key).
ssh_private_key_file = "/path/to/your/private_key"
