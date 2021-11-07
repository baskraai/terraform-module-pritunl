#!/bin/bash
sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Stable Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2/
gpgcheck=1
enabled=1
EOF
sudo gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp; sudo rpm --import key.tmp; rm -f key.tmp
sudo amazon-linux-extras install epel -y
sudo yum install pritunl-client -y
pritunl-client add pritunl://${server_fqdn}:${port}/ku/${profile}
pritunl-client start $(pritunl-client list | sed 's/|/ /' | awk '{print $1}' | grep -v '+--' | grep -v "ID" | head -n 1) --mode=ovpn
aws --region $(wget -q -O - http://169.254.169.254/latest/meta-data/placement/region) ec2 replace-route --route-table-id rtb-f88b8f90 --destination-cidr-block 192.168.0.0/16 --instance-id $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws --region $(wget -q -O - http://169.254.169.254/latest/meta-data/placement/region) ec2 replace-route --route-table-id rtb-f88b8f90 --destination-cidr-block 172.16.0.0/12 --instance-id $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws --region $(wget -q -O - http://169.254.169.254/latest/meta-data/placement/region) ec2 replace-route --route-table-id rtb-f88b8f90 --destination-cidr-block 10.0.0.0/8 --instance-id $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
sudo sysctl -w net.ipv4.ip_forward=1
