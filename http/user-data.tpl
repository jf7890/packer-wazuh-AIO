#cloud-config
autoinstall:
  version: 1
  locale: en_US.UTF-8
  keyboard:
    layout: us
  timezone: Asia/Ho_Chi_Minh

  identity:
    hostname: ${hostname}
    username: ubuntu
    password: "${ubuntu_password_hash}"

  ssh:
    install-server: true
    allow-pw: true
%{ if ssh_public_key != "" ~}
    authorized-keys:
      - "${ssh_public_key}"
%{ endif ~}

  apt:
    preserve_sources_list: false
    geoip: false
    primary:
      - arches: [amd64]
        uri: http://archive.ubuntu.com/ubuntu

  network:
    version: 2
    ethernets:
      eth0:
        match:
          name: "en*"
        dhcp4: true
        dhcp6: false
        optional: true

  packages:
    - sudo
    - curl
    - ca-certificates

  late-commands:
    - curtin in-target -- systemctl enable ssh
    - curtin in-target -- /bin/sh -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu"
    - curtin in-target -- chmod 440 /etc/sudoers.d/ubuntu
    - curtin in-target -- /bin/bash -lc 'export DEBIAN_FRONTEND=noninteractive; for i in 1 2 3 4 5; do apt-get update && apt-get install -y qemu-guest-agent && break; sleep 15; done'
    - curtin in-target -- systemctl enable qemu-guest-agent
