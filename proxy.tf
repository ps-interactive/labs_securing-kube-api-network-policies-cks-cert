/* This file is DO NOT TOUCH. Making adjustments to the contents of this file can break the lab environment. */
/* Proxy AMI */
data "aws_ami" "ps_proxy" {
  most_recent = true
  filter {
    name   = "name"
    values = ["PS-PROXY-*"]
  }
  owners = ["363597930206"]
}

/* Proxy Security Group */
resource "aws_security_group" "proxy" {
  name   = "proxy_rules"
  vpc_id = aws_vpc.lab_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

/* Proxy Credentials */
resource "random_string" "proxy_user" {
  length  = 5
  upper   = false
  lower   = true
  numeric  = true
  special = false
}

resource "random_string" "proxy_pwd" {
  length           = 16
  special          = false
  upper   = true
  lower   = true
  numeric  = true
}
resource "tls_private_key" "proxykey" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "terrakey-proxy" {
  key_name   = "proxy-key"
  public_key = tls_private_key.proxykey.public_key_openssh
}

/* Proxy boxy with tinyproxy */
resource "aws_instance" "forward-proxy" {
  ami                         = data.aws_ami.ps_proxy.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  hibernation                 = false
  instance_type               = "t3a.micro"
  private_ip                  = var.forward_proxy_static_ipv4_address
  monitoring                  = false
  subnet_id                   = aws_subnet.subnets["proxy"].id
  key_name                    = aws_key_pair.terrakey-proxy.key_name
  vpc_security_group_ids      = [aws_security_group.proxy.id]
  user_data = templatefile("${path.module}/user_data_scripts/proxy.sh", {
    proxy_user = random_string.proxy_user.result
    proxy_pwd = random_string.proxy_pwd.result
  })
  tags = {
    Name = "forward-proxy"
    # Protocol    = "ssh"
    # Username    = "ubuntu"
    # Private-Key = "${tls_private_key.proxykey.id}"
  }
  timeouts {}
}