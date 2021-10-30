terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.31.1"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Import the SSH-management-key
resource "hcloud_ssh_key" "pritunl-ssh-key" {
  count      = var.ssh["type"] == "file" ? 1 : 0
  name       = var.ssh.name
  public_key = file(var.ssh["path"])
  labels             = {
    terraform = true
  }
}

# Setup the server

resource "hcloud_server" "pritunl-server" {
  name               = "pritunl-01.${var.domain}"
  image              = "rocky-8"
  server_type        = "cpx11"
  location           = "hel1"
  ssh_keys           = var.server["ssh-access"] ? [resource.hcloud_ssh_key.pritunl-ssh-key[0].id] : []
  backups            = var.server["backup"]
  keep_disk          = true
  delete_protection  = true
  rebuild_protection = true
  labels             = {
    terraform = true
  }
}
