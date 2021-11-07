# Import the default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Import the most recent Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2-ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

}

# Create the iam role for the machine to update the routing table
resource "aws_iam_role" "ec2_role" {
  name = "PritunlEC2RouteUpdate"
  assume_role_policy = jsonencode(
  {
      Statement = [
          {
              Action    = "sts:AssumeRole"
              Effect    = "Allow"
              Principal = {
                  Service = "ec2.amazonaws.com"
              }
          },
      ]
      Version   = "2012-10-17"
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "PritunlEC2RouteUpdate"
  policy = jsonencode(
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": "ec2:ReplaceRoute",
              "Resource": "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:route-table/${resource.aws_default_vpc.default.main_route_table_id}"
          }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2-role-attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2-instance-role" {
  name = "PritunlEC2RouteUpdate"
  role = aws_iam_role.ec2_role.name
}

resource "aws_default_security_group" "default" {
  vpc_id = resource.aws_default_vpc.default.id
}

resource "aws_security_group" "pritunl-client" {
  name        = "pritunl-client"
  description = "The security group for the pritunl-client"
  vpc_id      = resource.aws_default_vpc.default.id

  ingress = [
    {
      description      = "Allow dynamic ports"
      from_port        = 1024
      to_port          = 65535
      protocol         = "tcp"
      cidr_blocks      = [resource.aws_default_vpc.default.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow dynamic ports"
      from_port        = 1024
      to_port          = 65535
      protocol         = "udp"
      cidr_blocks      = [resource.aws_default_vpc.default.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
        cidr_blocks      = [
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
        ]
        description      = ""
        from_port        = 0
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        protocol         = "-1"
        security_groups  = []
        self             = false
        to_port          = 0
    }
  ]

  egress = [
    {
      description      = "Allow all traffic to the outside"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_key_pair" "pritunl-ssh-key" {
  count      = var.ssh["type"] == "file" ? 1 : 0
  key_name   = var.ssh.name
  public_key = file(var.ssh["path"])
  tags       = {
    terraform = true
  }
}

resource "aws_instance" "pritunl-client" {
  count = var.aws_client["enabled"] ? 1 : 0
  ami = data.aws_ami.amazon-linux-2-ami.image_id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  source_dest_check = false
  ebs_optimized = false
  key_name = resource.aws_key_pair.pritunl-ssh-key[0].key_name
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids = [resource.aws_security_group.pritunl-client.id]
  user_data = base64encode(templatefile("${path.module}/aws_client_script.sh", { "profile" = var.aws_client["profile_token"], "server_fqdn" = var.server.server_fqdn, "port" = var.server.port } ) )
  iam_instance_profile = "PritunlEC2RouteUpdate"
  tags = {
    Name = "pritunl-client-aws"
  }
}
