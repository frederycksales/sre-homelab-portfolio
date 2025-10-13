# Home Lab Network Architecture

This document details the network topology of the Proxmox environment.

## Management Network (`vmbr0`)

- **Purpose:** Access to Proxmox web interface and host connectivity to the internet.
- **IP Range:** `192.168.50.0/24`
- **Gateway:** `192.168.50.1` (Main router IP)
- **Proxmox Host IP (pve):** `192.168.50.15`

## Lab Virtual Network / VPC (`vmbr1`)

- **Purpose:** Isolated network for communication between Kubernetes cluster nodes and other internal services. VMs on this network do not have direct internet access by default.
- **IP Range:** `10.10.10.0/24`
- **Gateway (on Proxmox):** N/A (Internal network)
- **Proxmox Host IP on this network:** `10.10.10.1`

### IP Allocation Plan (Kubernetes Cluster)

- `10.10.10.10`: k8s-control-plane-01
- `10.10.10.20`: k8s-worker-01
- `10.10.10.21`: k8s-worker-02