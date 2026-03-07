provider "proxmox" {
  endpoint = "https://${var.proxmox_server_ip}:8006/"

  insecure = true

  ssh {
    agent = true
  }
}
