variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "ssh" {
  type = object({
    name = string
    type = string
    path = string
  })
}

variable "server" {
  type = object({
    server_fqdn = string
    port = string
    backup = bool
    ssh-access = bool
  })
}

variable "domain" {
  type = string
}
