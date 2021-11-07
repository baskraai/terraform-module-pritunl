variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "pritunl_token" {
  type = object({
    token = string
    secret = string
  })
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

variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "aws_client" {
  type = object({
    enabled = bool
    profile_token = string
  })
}
