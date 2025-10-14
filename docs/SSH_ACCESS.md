# SSH Access Guide

## Architecture Overview

Access to the isolated Lab Virtual Network (`10.10.10.0/24`) is managed using a **Bastion Host** model, a standard cloud security practice. The Proxmox host (`pve-homelab-01`) serves as the single, secure entry point (jump host).

Direct SSH access to the Kubernetes nodes from outside the Proxmox host is prohibited by the network design. All connections must be proxied through the Bastion.

## Configuration

To enable seamless and secure connections for both interactive SSH and Ansible, configure your local SSH client by adding the following to your `~/.ssh/config` file.

This setup assumes you are using the **same SSH key pair** for both the Bastion Host and the internal Kubernetes nodes. The public key must be installed on the Proxmox host and also included in the OpenTofu configuration to be installed on the VMs by Cloud-Init.

```
# ==============================================================================
# PROXMOX SRE HOME LAB
# ==============================================================================

# 1. Bastion Host Configuration (Proxmox VE)
# Defines how to connect to the single entry point.
Host pve-homelab-01
  HostName <YOUR_PROXMOX_IP>
  Port <YOUR_PROXMOX_SSH_PORT>
  User root # Or your specific user for the Proxmox shell
  IdentityFile ~/.ssh/sre_homelab_key

# 2. Kubernetes Nodes Configuration (Private VMs)
# Defines how to access any node inside the isolated lab network.
Host 10.10.10.*
  User terraform
  # Use the same private key for the internal VMs
  IdentityFile ~/.ssh/sre_homelab_key
  # Instructs SSH to "jump" through the Bastion Host first
  ProxyJump pve-homelab-01

```

Replace `<YOUR_PROXMOX_IP>` and `<YOUR_PROXMOX_SSH_PORT>` with your actual Proxmox server details.

## Usage with a Passphrase-Protected Key

If your private key (`~/.ssh/sre_homelab_key`) is protected by a passphrase, you must load it into the `ssh-agent` to enable non-interactive automation with Ansible.

**Workflow for a new terminal session:**

1. **Start the agent:**
    
    ```bash
    eval $(ssh-agent -s)
    
    ```
    
2. **Add your key to the agent** (you will be prompted for the passphrase once per session):
    
    ```bash
    ssh-add ~/.ssh/sre_homelab_key
    
    ```
    

Once the key is added to the agent, all subsequent `ssh` and `ansible-playbook` commands will run securely without further prompts.