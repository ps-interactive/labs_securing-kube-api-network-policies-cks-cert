/*
Terrarium Version 4.3
Pluralsight Secure Labs Platform
Released: June 2024
*/

/* PSSEC Custom Ubuntu 22.04 with XFCE Desktop */
data "aws_ami" "pssec-u22d" {
  most_recent = true
  filter {
    name   = "name"
    values = ["PSSECURITY-U22D-BASE*"]
  }
  owners = ["363597930206"]
}

/* Learner-facing EC2 Instances */

/* RDP UBUNTU DESKTOP */

module "cloud_init_config_U22D" {
  source = "./cloudinit"

  cloudinit_parts = [
    {
      filepath     = "${path.module}/user_data_scripts/cloud-init.yaml"
      content-type = "text/cloud-config"
      vars = {
        win_rdp_password = "${random_string.password.result}"
      }
    },

    {
      filepath     = "${path.module}/user_data_scripts/nix-xrdp-console.sh"
      content-type = "text/x-shellscript"
      vars = {
        win_rdp_password       = random_string.version.result
        proxy_user = random_string.proxy_user.result
        proxy_pwd = random_string.proxy_pwd.result
      }
    }
  ]
}

resource "aws_instance" "nix-xrdp-console" {
  ami                         = data.aws_ami.pssec-u22d.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t3.medium"
  # private_ip                  = "172.31.24.30"
  # ipv6_address_count          = 0
  # ipv6_addresses              = []
  monitoring                  = false
  subnet_id                   = aws_subnet.subnets["consoles"].id
  key_name                    = aws_key_pair.terrakey.key_name
  vpc_security_group_ids      = [aws_security_group.xrdp_console.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }
  tags = {
    Name = "Ubuntu Desktop"
    Protocol = "rdp"
    Username = "pslearner"
    Password = "${random_string.password.result}"
    Security = "any"
    Ignore-Cert = "true"
  }
  user_data_base64 = module.cloud_init_config_U22D.cloud_init_config_gzip
  timeouts {}
}

/* EOL FOR RDP UBUNTU DESKTOP */

/* EOL for Learner-facing EC2 Instances */

/* 
Non-user EC2 Instances 
Remove "Tags" and a connection will not be created.
*/

/* EOL for Non-user EC2 Instances */