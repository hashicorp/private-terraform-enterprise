terraform {
  required_version = ">= 0.11.13"
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block  = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.namespace}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.namespace}-internet-gateway"
  }
}

resource "aws_eip" "ngw" {
  vpc      = true
  depends_on = ["aws_internet_gateway.main"]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.ngw.id}"
  subnet_id     = "${aws_subnet.public.0.id}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = ["${aws_route_table.private.id}"]
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.namespace}-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "${var.namespace}-private-route-table"
  }
}

locals {
  segmented_cidr = "${split("/", var.cidr_block)}"
  address = "${split(".", local.segmented_cidr[0])}"
  bits = "${local.segmented_cidr[1]}"
}

resource "aws_subnet" "private" {
  count             = "${var.subnet_count}"
  cidr_block = "${format("%s.%s.%d.%s/%d", local.address[0], local.address[1], count.index+1, local.address[3], local.bits + (32 - local.bits) / 2)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index % 2)}"

  tags {
    Name = "${var.namespace}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }

  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  count      = "${var.subnet_count}"
  cidr_block = "${format("%s.%s.%d.%s/%d", local.address[0], local.address[1], var.subnet_count + count.index + 1, local.address[3], local.bits + (32 - local.bits) / 2)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index % 2)}"

  tags {
    Name = "${var.namespace}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private" {
  count          = "${var.subnet_count}"
  route_table_id = "${aws_route_table.private.id}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.subnet_count}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_security_group" "main" {
  name        = "${var.namespace}-sg"
  description = "${var.namespace} security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### EC2 instance
resource "aws_instance" "bastion" {
  ami                    = "ami-0565af6e282977273"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.public.0.id}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  key_name               = "${var.ssh_key_name}"
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags {
    Name  = "${var.namespace}-bastion"
  }
}
