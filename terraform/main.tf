# terraform/main.tf

# ==============================================================================
# CONTROL PLANE
# ==============================================================================

resource "proxmox_vm_qemu" "control_plane" {
  name        = "k8s-control-plane-01"
  description = "Control Plane do cluster Kubernetes (gerenciado por OpenTofu)"
  target_node = "pve-homelab-01"

  # Origem
  clone      = "template-debian13-cloud-init-agent"
  full_clone = true

  # Recursos
  cpu {
    cores   = 2
    sockets = 1
  }
  memory = 4096

  # Boot e Agent
  boot  = "order=scsi0"
  agent = 1

  # Rede
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
  }

  # Disco
  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = "local-lvm"
    size    = "30G"
  }

  # Cloud-Init
  ipconfig0 = "ip=10.10.10.10/24,gw=10.10.10.1"
  sshkeys   = var.ssh_public_key

  lifecycle {
    ignore_changes = [network]
  }
}

# ==============================================================================
# WORKER NODES
# ==============================================================================

resource "proxmox_vm_qemu" "workers" {
  count = 2

  name        = "k8s-worker-0${count.index + 1}"
  description = "Worker node do cluster Kubernetes (gerenciado por OpenTofu)"
  target_node = "pve-homelab-01"

  # Origem
  clone      = "template-debian13-cloud-init-agent"
  full_clone = true

  # Recursos
  cpu {
    cores   = 2
    sockets = 1
  }
  memory = 2048

  # Boot e Agent
  boot  = "order=scsi0"
  agent = 1

  # Rede
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
  }

  # Disco
  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = "local-lvm"
    size    = "30G"
  }

  # Cloud-Init
  ipconfig0 = "ip=10.10.10.${20 + count.index}/24,gw=10.10.10.1"
  sshkeys   = var.ssh_public_key

  lifecycle {
    ignore_changes = [network]
  }
}