/* Availability zones data source for subnet creation */
data "aws_availability_zones" "available" {
  state = "available"
}

/*
Custom VPC shows the use of tags to name resources
Instance Tenancy set to `default` is not to be confused with the concept of a Default VPC
*/
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Lab VPC"
  }
}

resource "aws_security_group" "ssh_console" {
  name   = "ssh_console"
  vpc_id = aws_vpc.lab_vpc.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "ssh_to_proxy" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["${var.forward_proxy_static_ipv4_address}/32"]
  security_group_id = aws_security_group.ssh_console.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "tudor_to_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.tudor_cluster_ip_addresses
  security_group_id = aws_security_group.ssh_console.id
}

resource "aws_security_group" "xrdp_console" {
  name   = "xrdp_console"
  vpc_id = aws_vpc.lab_vpc.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "xrdp_to_proxy" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["${var.forward_proxy_static_ipv4_address}/32"]
  security_group_id = aws_security_group.xrdp_console.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "tudor_to_xrdp" {
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = var.tudor_cluster_ip_addresses
  security_group_id = aws_security_group.xrdp_console.id
}

resource "aws_security_group" "rdp_console" {
  name   = "rdp_console"
  vpc_id = aws_vpc.lab_vpc.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "rdp_to_proxy" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["${var.forward_proxy_static_ipv4_address}/32"]
  security_group_id = aws_security_group.rdp_console.id
}

/* REQUIRED SECURITY GROUP RULES. DO NOT EDIT. */
resource "aws_security_group_rule" "tudor_to_rdp" {
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = var.tudor_cluster_ip_addresses
  security_group_id = aws_security_group.rdp_console.id
}

/* Custom Internet Gateway - not created as part of the initialization of a VPC */
resource "aws_internet_gateway" "lab_vpc_gateway" {
  vpc_id = aws_vpc.lab_vpc.id
}
/*
Create a Route in the Main Routing Table - no need to create a Custom Routing Table
Use `main_route_table_id` to pull the ID of the main routing table
*/
resource "aws_route" "lab_vpc_internet_access" {
  route_table_id         = aws_vpc.lab_vpc.main_route_table_id
  destination_cidr_block = var.default_route_cidr_block
  gateway_id             = aws_internet_gateway.lab_vpc_gateway.id
}

/* Create subnets from var.lab_vpc_subnet_list */
resource "aws_subnet" "subnets" {
  for_each = var.lab_vpc_subnet_list

  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = each.key
  }
}

/* EDIT SECURITY GROUP RULES BELOW */

/* Security Group Rules For Ubuntu Console */

/* EGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "ssh_rule_1" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.ssh_console.id
}

/* INGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "ssh_rule_2" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.ssh_console.id
}

/* Security Group Rules For Ubuntu Desktop */

/* EGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "xrdp_rule_1" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.xrdp_console.id
}

/* INGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "xrdp_rule_2" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.xrdp_console.id
}

/* Security Group Rules For Windows Desktop */

/* EGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "rdp_rule_1" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.rdp_console.id
}

/* INGRESS allowed to all other devices created by default, restrict as you see fit. */
resource "aws_security_group_rule" "rdp_rule_2" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = [var.lab_vpc_cidr_block]
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.rdp_console.id
}