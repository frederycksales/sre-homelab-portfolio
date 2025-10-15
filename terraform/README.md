# Terraform - Kubernetes Cluster Infrastructure

This directory contains the Terraform configuration for provisioning a Kubernetes cluster on Proxmox VE.

## Structure

- `provider.tf`: Proxmox provider configuration
- `variables.tf`: Variable definitions
- `main.tf`: Infrastructure resources (control plane and worker nodes)
- `terraform.tfvars`: Variable values (not committed)

## Infrastructure

The configuration provisions:
- 1 Control Plane node (k8s-control-plane-01, 10.10.10.10)
- 2 Worker nodes (k8s-worker-01/02, 10.10.10.20-21)

All VMs are cloned from the `template-debian12-cloud-init-agent` template.

## Prerequisites

- OpenTofu or Terraform installed
- Proxmox VE API token
- SSH public keys for access
- A Cloud-Init template available in Proxmox. See the **[Proxmox Template Guide](../docs/PROXMOX_TEMPLATE_GUIDE.md)** for creation instructions.

## Configuration

Create a `terraform.tfvars` file with your credentials:

```hcl
proxmox_api_token_id        = "your-token-id"
proxmox_api_token_secret    = "your-token-secret"
ssh_public_key              = "ssh-rsa AAAA... your-key"
ansible_host_ssh_public_key = "ssh-rsa AAAA... ansible-key"
```

## Usage

Initialize and apply the configuration:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

To destroy the infrastructure:

```bash
terraform destroy
```

## Security Notes

- Never commit `terraform.tfvars` or `*.tfstate` files
- Use least-privilege API tokens
- Store credentials in a secure secrets manager