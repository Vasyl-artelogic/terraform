resource "aws_vpc" "my-tf-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = var.vpc_name
  }
}


resource "aws_internet_gateway" "my-tf-gw" {
  vpc_id = aws_vpc.my-tf-vpc.id
}


resource "aws_subnet" "my-tf-subnet" {
  vpc_id            = aws_vpc.my-tf-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-central-1a"
}


resource "aws_subnet" "my-tf-db-subnet" {
  vpc_id            = aws_vpc.my-tf-vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-central-1a"
}


resource "aws_subnet" "my-tf-db-subnet2" {
  vpc_id            = aws_vpc.my-tf-vpc.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_route_table" "my-tf-table" {
  vpc_id = aws_vpc.my-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-tf-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.my-tf-gw.id
  }
}


resource "aws_route_table_association" "rt_association_ec2" {
  subnet_id      = aws_subnet.my-tf-subnet.id
  route_table_id = aws_route_table.my-tf-table.id
}


resource "aws_route_table_association" "rt_association_db" {
  subnet_id      = aws_subnet.my-tf-db-subnet.id
  route_table_id = aws_route_table.my-tf-table.id
}


resource "aws_security_group" "sg-db-ter" {
  name        = "second-sg-ter"
  vpc_id      = aws_vpc.my-tf-vpc.id
  description = "this security group allow inbound 3306 port for ec2 and all ips and all ports for outbounds ruls"
}


resource "aws_vpc_security_group_ingress_rule" "allow_ec2" {
  security_group_id = aws_security_group.sg-db-ter.id

  cidr_ipv4   = "${var.ec2_ip}/32"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}


resource "aws_vpc_security_group_egress_rule" "allow" {
  security_group_id = aws_security_group.sg-db-ter.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "sg-ter" {
  name        = "first-sg-ter"
  vpc_id      = aws_vpc.my-tf-vpc.id
  description = "this security group allow inbound 80 and 22 ports for 3 ips and all ips and all ports for outbounds ruls "
}

resource "aws_vpc_security_group_ingress_rule" "allow_office" {
  security_group_id = aws_security_group.sg-ter.id

  cidr_ipv4   = var.office_ip
  for_each    = var.sg_ports
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
}

resource "aws_vpc_security_group_ingress_rule" "allow_OIsniuk" {
  security_group_id = aws_security_group.sg-ter.id

  cidr_ipv4   = var.OIsniuk_ip
  for_each    = var.sg_ports
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
}

resource "aws_vpc_security_group_ingress_rule" "allow_home" {
  security_group_id = aws_security_group.sg-ter.id

  cidr_ipv4   = var.my_home_ip
  for_each    = var.sg_ports
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.sg-ter.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_db_subnet_group" "my_ter_db_sub_gr" {
  name       = "my first subnet group"
  subnet_ids = [aws_subnet.my-tf-db-subnet.id, aws_subnet.my-tf-db-subnet2.id] 
}