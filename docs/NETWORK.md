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

---

## Host-Level Network Configuration (`pve-homelab-01`)

To enable the isolated Lab Virtual Network (`vmbr1`) to access the internet for essential tasks like downloading packages, the Proxmox host itself must be configured to act as a network gateway. This involves enabling IP forwarding, setting up a NAT (Masquerading) rule, and providing DNS resolution.

These steps are performed manually on the Proxmox host shell and are prerequisites for the Ansible playbooks to run successfully.

### 1. Enable IP Forwarding

This allows the host to forward network packets from the private `vmbr1` interface to the public `vmbr0` interface.

**Command:**
```bash
# Create a dedicated sysctl configuration file
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-pve-forwarding.conf

# Apply the setting without rebooting
sysctl -p /etc/sysctl.d/99-pve-forwarding.conf
```

### 2. Configure NAT with `iptables`

This rule "masquerades" traffic from the `10.10.10.0/24` network, making it appear as if it originates from the Proxmox host's own IP address (`192.168.50.15`).

**Commands:**
```bash
# Add the POSTROUTING rule for NAT
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o vmbr0 -j MASQUERADE

# Install iptables-persistent to save the rule across reboots
apt-get update
apt-get install iptables-persistent -y
```
*(During the installation, accept the prompts to save the current IPv4 and IPv6 rules).*

### 3. Provide DNS Resolution with `dnsmasq`

The Kubernetes nodes are configured to use the Proxmox host (`10.10.10.1`) as their DNS server. The `dnsmasq` service is installed on the host to listen for these DNS queries on `vmbr1` and forward them to upstream DNS servers.

**Commands:**
```bash
# Install dnsmasq
apt-get install dnsmasq -y

# Create a dedicated configuration to listen only on the necessary interfaces
cat <<EOF > /etc/dnsmasq.d/10-pve-homelab.conf
# Listen for DNS queries only on the loopback and lab network interfaces
interface=lo
interface=vmbr1

# Do not act as a DHCP server
no-dhcp-interface=lo
no-dhcp-interface=vmbr1
EOF

# Restart the service to apply the new configuration
systemctl restart dnsmasq
```