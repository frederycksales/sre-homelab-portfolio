# Ansible Configuration

This directory contains the Ansible automation for configuring the Kubernetes nodes after they have been provisioned by OpenTofu.

## Structure

-   `ansible.cfg`: Default configuration for the project.
-   `inventory.ini`: Static inventory of the cluster nodes.
-   `site.yml`: The main playbook that orchestrates the application of all roles.
-   `roles/`: Contains reusable roles for modular configuration.
    -   `common`: Applies a common baseline configuration to all nodes (updates, essential packages, etc.).
    -   `k3s`: Installs the K3s Kubernetes distribution.

## Prerequisites: SSH Access

Before running any playbooks, your local SSH client must be configured to connect to the private lab network via the Proxmox Bastion Host.

This requires two components:
1.  **SSH Config (`~/.ssh/config`):** Your client must be configured with a `ProxyJump` to route traffic through the bastion.
2.  **SSH Agent:** To handle passphrase-protected keys non-interactively, your private key must be loaded into the `ssh-agent`.

Please refer to the main `SSH_ACCESS.md` file in the root of the repository for the detailed setup instructions.

## How to Run

1.  Ensure your SSH Agent is running and your key has been added:
    ```bash
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/sre_homelab_key
    ```

2.  Navigate to this directory (`/ansible`).

3.  Execute the main playbook:
    ```bash
    ansible-playbook site.yml
    ```