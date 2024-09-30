terraform {
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

resource "aws_instance" "my_first_ter_ec2" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "key_to_ec2_1st_task"
  vpc_security_group_ids = ["${aws_security_group.sg-ter.id}"]
  tags = {
    Name = "my_first_ter_ec2"
  }
}



resource "aws_security_group" "sg-ter" {
  name = "first-sg-ter"
  description = "this security group allow 80 port and all port for outbounds ruls "
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.sg-ter.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.app_port
  ip_protocol = "tcp"
  to_port = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.sg-ter.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1" 
  
}

output "public_ip" {
  value = "curl http://${aws_instance.my_first_ter_ec2.public_ip}:80"
}

/*
output "sg_id" {
  value = aws_security_group.sg-ter.id
}
*/