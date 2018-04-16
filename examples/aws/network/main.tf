data "aws_availability_zones" "available" {
  state = "available"
}

#------------------------------------------------------------------------------
# vpc / subnets / route tables / igw
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.namespace}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.namespace}-internet_gateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.namespace}-route_table"
  }
}

resource "aws_subnet" "main" {
  count             = 2
  cidr_block        = "10.0.${count.index+1}.0/24"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags {
    Name = "${var.namespace}-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
  }

  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.namespace}"
  description = "${var.namespace}-db_subnet_group"
  subnet_ids  = ["${aws_subnet.main.*.id}"]
}

resource "aws_route_table_association" "main" {
  count          = 2
  route_table_id = "${aws_route_table.main.id}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
}

#------------------------------------------------------------------------------
# security groups
#------------------------------------------------------------------------------

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
