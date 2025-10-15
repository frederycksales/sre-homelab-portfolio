# Proxmox Cloud-Init Template Creation Guide

This guide details how to create a reusable Proxmox VM template based on a cloud image. This template will serve as the base for all Kubernetes nodes provisioned by Terraform.

The steps should be executed on the Proxmox host's shell.

---

## Step 1: Download the Cloud Image

First, download a cloud-init ready image. We will use the official Debian 12 cloud image as an example.

```bash
# Download the image to your home directory
wget -P ~/ https://cloud.debian.org/cdimage/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
```

## Step 2: Create and Configure the Base VM

Next, create a virtual machine that will be converted into a template. We will use a high VM ID (e.g., 9000) to avoid conflicts with regular VMs.

1.  **Create the VM:**
    
    ```bash
    # VM ID 9000, 2GB RAM, 1 Core
    qm create 9000 --name "template-debian12-cloud-init" --memory 2048 --cores 1 --net0 virtio,bridge=vmbr0
    ```
    
2.  **Import the downloaded image** to the VM's storage. Replace `local-lvm` with your target storage if needed.
    
    ```bash
    qm importdisk 9000 ~/debian-12-generic-amd64.qcow2 local-lvm
    ```
    
3.  **Attach the imported disk** to the VM as a SCSI device.
    
    ```bash
    qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
    ```
    
4.  **Add a Cloud-Init drive.** This is essential for cloud-init to function.
    
    ```bash
    qm set 9000 --ide2 local-lvm:cloudinit
    ```
    
5.  **Set the boot disk** to the imported image.
    
    ```bash
    qm set 9000 --boot c --bootdisk scsi0
    ```
    
6.  **Configure a serial console.** This is a best practice for cloud-init images.
    
    ```bash
    qm set 9000 --serial0 socket --vga serial0
    ```

## Step 3: Install the QEMU Guest Agent via Cloud-Init

To ensure the QEMU Guest Agent is installed on first boot, we will pre-configure the template's cloud-init settings. This avoids having to manually start the VM and install it.

```bash
# This command tells cloud-init to run 'apt-get update' and install the guest agent on its first boot.
qm set 9000 --ciuser root --cipassword 'password' --cicustom "user=local:snippets/user-data.yaml"
```
*Note: The password set here is temporary and will be overwritten by the cloud-init data provided by Terraform during VM creation.*

You will need to create the referenced `user-data.yaml` file in your Proxmox snippets location (e.g., `/var/lib/vz/snippets/user-data.yaml`) with the following content:
```yaml
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - [ systemctl, enable, qemu-guest-agent ]
  - [ systemctl, start, qemu-guest-agent ]
```

## Step 4: Convert the VM to a Template

Finally, convert the configured VM into a template. A template cannot be started, but it can be cloned rapidly.

```bash
qm template 9000
```

The template `template-debian12-cloud-init` is now ready to be used by Terraform.
