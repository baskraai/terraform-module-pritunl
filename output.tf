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
output "pritunl-aws-client" {
  description = "The config of the pritunl-aws-client"
  value = {
    hostname       = resource.aws_instance.pritunl-client[0].public_dns
    server_connect = "ec2-user@${resource.aws_instance.pritunl-client[0].public_ip}"
    ipv4_public    = resource.aws_instance.pritunl-client[0].public_ip
    status         = resource.aws_instance.pritunl-client[0].instance_state
  }
}
