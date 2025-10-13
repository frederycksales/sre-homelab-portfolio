# terraform/variables.tf

variable "proxmox_api_token_id" {
  type        = string
  description = "O ID do token de API do Proxmox."
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "O segredo do token de API do Proxmox."
  sensitive   = true
}

variable "ssh_public_key" {
  type = string
  description = "Chave pública SSH para acessar as VMs sem senha."
}