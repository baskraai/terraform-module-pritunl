provider "pritunl" {
  url      = "https://${var.server.server_fqdn}:${var.server.port}"
  token    = var.pritunl_token.token
  secret   = var.pritunl_token.secret
  insecure = false
}

resource "pritunl_organization" "default" {
  name = "FamilieKraai"
}

resource "pritunl_user" "aws" {
  name            = "vpn-aws"
  organization_id = resource.pritunl_organization.default.id
  groups = [
    "site-to-site",
  ]
  network_links = [
    resource.aws_default_vpc.default.cidr_block,
  ]
}
