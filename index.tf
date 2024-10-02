terraform {

  required_version = ">=1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
}

resource "aws_vpc" "my-tf-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-tf-vpc"
  }
}

resource "aws_internet_gateway" "my-tf-gw" {
  vpc_id = aws_vpc.my-tf-vpc.id
 
}

resource "aws_subnet" "my-tf-subnet" {
  vpc_id            = aws_vpc.my-tf-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "my-tf-subnet"
  }
}

resource "aws_route_table" "my-tf-table" {
  vpc_id = aws_vpc.my-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-tf-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.my-tf-gw.id
  }

  tags = {
    Name = "my-tf-rt"
  }
  
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.my-tf-subnet.id
  route_table_id = aws_route_table.my-tf-table.id
  
}
resource "aws_security_group" "sg-ter" {
  name = "first-sg-ter"
  vpc_id = aws_vpc.my-tf-vpc.id
  description = "this security group allow inbound 80 port for ip 91.245.72.98 and all ips and all ports for outbounds ruls "
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.sg-ter.id
  
  cidr_ipv4 = "91.245.72.98/32"
  /*
  cidr_ipv4 = "0.0.0.0/0"
  */
  from_port = var.app_port
  ip_protocol = "tcp"
  to_port = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.sg-ter.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" 
  
}
/*
resource "aws_network_interface" "my-tf-ni" {
  subnet_id   = aws_subnet.my-tf-subnet.id
  private_ips = ["10.0.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
*/


resource "aws_instance" "my_first_ter_ec2" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "key_to_ec2_1st_task"
  availability_zone = "eu-central-1a"
  subnet_id = aws_subnet.my-tf-subnet.id
  associate_public_ip_address = "true"
/*  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.my-tf-ni.id
  }
*/


  vpc_security_group_ids = ["${aws_security_group.sg-ter.id}"]




  tags = {
    Name = "my_first_ter_ec2"
  }
}


output "public_ip" {
  value = "curl http://${aws_instance.my_first_ter_ec2.public_ip}:80"
}

/*
output "sg_id" {
  value = aws_security_group.sg-ter.id
}
*/

data "aws_instances" "name" {
  
}