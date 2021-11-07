# Terraform Module Pritunl
An terraform module that deploys a pritunl-server-systea with potentional clients.

# Requirements

- Terraform v1.0.9
- hetznercloud/hcloud >=v1.31.0
- hashicorp/aws >= v3.63.0

# Deploy

```hcl
module "pritunl-server" {
  source = "github.com/baskraai/terraform-module-pritunl?ref=v0.0.2"

  hcloud_token = "<token_hetzner_cloud"

  aws_region = "<aws_region>"

  ssh = {
    name = "<key_name>"
    type = "file"
    path = "~/.ssh/id_rsa.pub"
  }

  server = {
    server_fqdn = "<pritunl_server_fqdn>"
    port = "<pritunl_https_port>"
    backup = true
    ssh-access = false
  }

  domain = "<domain_suffix_for_server>"

  aws_client = {
    enabled = true
    profile_token = "<pritunl_24_hour_profile_token>"
  }

  pritunl_token = {
    token = "<pritunl_user_token>"
    secret = "<pritunl_user_secret>"
  }

}

output "pritunl-server" {
  value = module.pritunl-server.pritunl-server
  description = "The config of the Pritunl server"
}

output "pritunl-aws-client" {
  value = module.pritunl-server.pritunl-aws-client
  description = "The config of the Pritunl aws client"
}
```

