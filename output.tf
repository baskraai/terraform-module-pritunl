output "pritunl-server" {
  description = "The config of the pritunl-server"
  value = {
    hostname       = resource.hcloud_server.pritunl-server.name
    server_connect = "https://${var.server.server_fqdn}:${var.server.port}"
    ipv4           = resource.hcloud_server.pritunl-server.ipv4_address
    ipv6           = resource.hcloud_server.pritunl-server.ipv6_address
    status         = resource.hcloud_server.pritunl-server.status
  }
}
