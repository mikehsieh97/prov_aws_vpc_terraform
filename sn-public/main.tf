## Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.subnet_cidr}"
  availability_zone = "${var.subnet_az}"
  tags {
    Name = "${var.subnet_name}"
  }
}

## Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "igw_${var.subnet_name}"
  }
}

## Routing table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "rt_${var.subnet_name}"
  }
}

## Associate the routing table to public subnet
resource "aws_route_table_association" "rt_assn" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

## Create a private key that'll be used for access to Bastion host
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_access" {
  key_name = "bastion_access"
  public_key = "${tls_private_key.bastion_key.public_key_openssh}"
}
