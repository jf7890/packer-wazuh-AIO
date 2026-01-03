#cloud-config
autoinstall:
  version: 1
  locale: en_US.UTF-8
  keyboard:
    layout: us
  timezone: Asia/Ho_Chi_Minh

  # Ubuntu autoinstall requires a non-root user; SSH password login is disabled anyway.
  identity:
    hostname: ${hostname}
    username: ubuntu
    password: "${ubuntu_password_hash}"

  ssh:
    install-server: true
    allow-pw: false
    authorized-keys:
      - ${ssh_public_key}

  # Bring up eth0 via DHCP during install (mgmt NIC / vmbr10)
  network:
    version: 2
    ethernets:
      eth0:
        dhcp4: true
        dhcp6: false

  packages:
    - qemu-guest-agent
    - curl
    - ca-certificates

  late-commands:
    # ---- QEMU Guest Agent (Packer Proxmox builder uses this for IP discovery) ----
    - curtin in-target --target=/target -- systemctl enable qemu-guest-agent > /dev/null 2>&1 || true
    - curtin in-target --target=/target -- systemctl start  qemu-guest-agent > /dev/null 2>&1 || true

    # ---- Persist legacy interface naming so vm_interface="eth0" remains valid after reboot ----
    - curtin in-target --target=/target -- bash -c 'set -e; for f in /etc/default/grub /etc/default/grub.d/99-netnames.cfg; do [ -f "$f" ] || continue; grep -q "net.ifnames=0" "$f" && continue; sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 biosdevname=0 /" "$f" || true; sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0 /" "$f" || true; done; update-grub > /dev/null 2>&1 || true'

    # ---- Root SSH: key-only + PermitRootLogin prohibit-password ----
    - curtin in-target --target=/target -- bash -c 'install -d -m 0700 /root/.ssh'
    - curtin in-target --target=/target -- bash -c 'printf "%s\n" "${ssh_public_key}" > /root/.ssh/authorized_keys && chmod 0600 /root/.ssh/authorized_keys'

    # Ubuntu often locks root; unlock and delete password so key-based SSH works (SSH password auth stays disabled).
    - curtin in-target --target=/target -- bash -c 'passwd -d root > /dev/null 2>&1 || true; passwd -u root > /dev/null 2>&1 || true'

    - curtin in-target --target=/target -- bash -c 'install -m 0644 /dev/null /etc/ssh/sshd_config.d/99-root-keyonly.conf'
    - curtin in-target --target=/target -- bash -c 'printf "%s\n" "PermitRootLogin prohibit-password" "PasswordAuthentication no" "KbdInteractiveAuthentication no" "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config.d/99-root-keyonly.conf'

    - curtin in-target --target=/target -- bash -c 'systemctl enable ssh > /dev/null 2>&1 || true'
    - curtin in-target --target=/target -- bash -c 'systemctl reload ssh > /dev/null 2>&1 || true'
