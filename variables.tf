locals {
  ps_pw = rsadecrypt(filebase64("./keys/pw.enc"), file("./keys/private-key.pem"))
}

resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}

resource "random_string" "user_name" {
  length  = 4
  upper   = false
  lower   = true
  numeric  = true
  special = false
}

resource "random_string" "password" {
  length           = 16
  special          = true
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!"
}

/* Technically not a variable, but it's performing a similar function to what some of the random_string stuff is doing. */
resource "tls_private_key" "pki" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "terrakey" {
  key_name   = "lab-key"
  public_key = tls_private_key.pki.public_key_openssh
}

resource "tls_private_key" "ed25519" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "terrakey-ed25519" {
  key_name   = "lab-key-ed25519"
  public_key = trimspace(tls_private_key.ed25519.public_key_openssh)
}

/* AWS Region */
variable "aws_region" {
  type        = string
  description = "(Optional) Sets the region used by the AWS provider. Defaults to us-west-2."
  default     = "us-west-2"
}


/* Default route CIDR block */
variable "default_route_cidr_block" {
  type        = string
  description = "(Optional) Configure the destination for the default route. Defaults to 0.0.0.0/0"
  default     = "0.0.0.0/0"
}


/* Lab VPC CIDR Block */
variable "lab_vpc_cidr_block" {
  type        = string
  description = "(Optional) CIDR Block to use for the lab vpc. Defaults to 172.31.0.0/16"
  default     = "172.31.0.0/16"
}

/*
Forward Proxy Static IP address
Must be in the range lab vpc CIDR block
*/
variable "forward_proxy_static_ipv4_address" {
  type        = string
  description = "(Optional) Static IP address for the forward proxy EC2 instance. Defaults to 172.31.245.222."
  default     = "172.31.245.222"
}

variable "tudor_cluster_ip_addresses" {
  type        = list(string)
  description = "(Optional) CIDR Blocks to allow SSH and RDP from."
  default     = ["172.31.245.223/32", "52.42.34.111/32", "35.162.190.211/32", "52.36.220.5/32"]
}

variable "lab_vpc_subnet_list" {
  type        = map(string)
  description = "(Optional) Map of subnet names (key) and CIDR Blocks to use (value)"
  default = {
    proxy    = "172.31.245.0/24"
    consoles = "172.31.24.0/24"
    enva     = "172.31.37.0/24"
    envb     = "172.31.64.0/24"
  }
}

