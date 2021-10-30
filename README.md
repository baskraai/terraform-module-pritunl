# Terraform Module Pritunl
An terraform module that deploys a pritunl-server-systea with potentional clients.

# Requirements

- Terraform v1.0.9
- hetznercloud/hcloud >v1.31.0

# Deploy

```hcl
module "pritunl-server" {
  source = "github.com/baskraai/terraform-module-pritunl?ref=v0.0.1"

  hcloud_token = "<token_hetzner_cloud"

  ssh = {
    name = "<key_name>"
    type = "file"
    path = "~/.ssh/id_rsa.pub"
  }

  server = {
    server_fqdn = "Pritunl-server-fqdn"
    port = "<pritunl_https_port>"
    backup = true
    ssh-access = false
  }

  domain = "<domain_suffix_for_server>"

}

output "pritunl-server" {
  value = module.pritunl-server.pritunl-server
  description = "The config of the Pritunl server"
}
```

