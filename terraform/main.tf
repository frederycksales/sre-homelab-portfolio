# terraform/main.tf

# ==============================================================================
# CONTROL PLANE
# ==============================================================================

resource "proxmox_vm_qemu" "control_plane" {
  vmid        = 100
  name        = "k8s-control-plane-01"
  description = "Control Plane do cluster Kubernetes (gerenciado por OpenTofu)"
  target_node = "pve-homelab-01"

  clone      = "template-debian13-cloud-init-agent"
  full_clone = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 4096

  scsihw = "virtio-scsi-single"

  boot             = "order=scsi0"
  agent            = 1
  onboot           = true
  startup          = "order=1,up=30"
  automatic_reboot = false

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
  }

  disk {
    slot     = "scsi0"
    type     = "disk"
    storage  = "local-lvm"
    size     = "30G"
    discard  = true
    iothread = true
  }

  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  ipconfig0  = "ip=10.10.10.10/24,gw=10.10.10.1"
  nameserver = "10.10.10.1"
  sshkeys    = trimspace(<<EOT
  ${var.ssh_public_key}
  ${var.ansible_host_ssh_public_key}
  EOT
  )
  ciuser     = "terraform"

  lifecycle {
    ignore_changes = [network, disk]
  }
}

# ==============================================================================
# WORKER NODES
# ==============================================================================

resource "proxmox_vm_qemu" "workers" {
  count = 3

  vmid        = 110 + count.index
  name        = "k8s-worker-0${count.index + 1}"
  description = "Worker node do cluster Kubernetes (gerenciado por OpenTofu)"
  target_node = "pve-homelab-01"

  clone      = "template-debian13-cloud-init-agent"
  full_clone = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 4096

  scsihw = "virtio-scsi-single"

  boot             = "order=scsi0"
  agent            = 1
  onboot           = true
  startup          = "order=2,up=30"
  automatic_reboot = false

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
  }

  disk {
    slot     = "scsi0"
    type     = "disk"
    storage  = "local-lvm"
    size     = "30G"
    discard  = true
    iothread = true
  }

  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  ipconfig0  = "ip=10.10.10.${20 + count.index}/24,gw=10.10.10.1"
  nameserver = "10.10.10.1"
  sshkeys    = trimspace(<<EOT
  ${var.ssh_public_key}
  ${var.ansible_host_ssh_public_key}
  EOT
  )
  ciuser     = "terraform"

  lifecycle {
    ignore_changes = [network, disk]
  }

  depends_on = [proxmox_vm_qemu.control_plane]
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "control_plane_ip" {
  description = "IP do Control Plane"
  value       = proxmox_vm_qemu.control_plane.default_ipv4_address
}

output "worker_ips" {
  description = "IPs dos Worker Nodes"
  value       = proxmox_vm_qemu.workers[*].default_ipv4_address
}

output "control_plane_ssh" {
  description = "Comando SSH para Control Plane"
  value       = "ssh terraform@${proxmox_vm_qemu.control_plane.default_ipv4_address}"
}