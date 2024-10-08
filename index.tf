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
  region = "eu-central-1"
}


resource "aws_vpc" "my-tf-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
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
  availability_zone = "eu-central-1b"
}


resource "aws_subnet" "my-tf-db-subnet2" {
  vpc_id            = aws_vpc.my-tf-vpc.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "eu-central-1c"
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


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my-tf-subnet.id
  route_table_id = aws_route_table.my-tf-table.id

}


resource "aws_route_table_association" "b" {
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

  cidr_ipv4   = "${aws_instance.my_first_ter_ec2.private_ip}/32"
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


resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "my_terraform_db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admino"
  password             = "passwordino"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.my_ter_db_sub_gr.id
  vpc_security_group_ids = [aws_security_group.sg-db-ter.id]
}

/*
data "aws_ami" "check_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  description : for check latest versions of  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server
}
*/


resource "aws_instance" "my_first_ter_ec2" {

  ami                         = "ami-06745ff0faf1df769"
  instance_type               = "t2.micro"
  key_name                    = "key_to_ec2_1st_task"
  availability_zone           = "eu-central-1a"
  subnet_id                   = aws_subnet.my-tf-subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.sg-ter.id}"]
  lifecycle {
    ignore_changes = [ tags ]
  }
  tags = {
    Name = "my_first_ter_ec2"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("./terraform-key.pem")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt update && sudo apt install mysql-server -y"
    ]
    
  }

  /*
  ami = data.aws_ami.check_ami.image_id
  description : it's check data wich ami is latest
  
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.my-tf-ni.id
    description : it's like phisical network card
  }
*/
}


output "public_ip" {
  value = "curl http://${aws_instance.my_first_ter_ec2.public_ip}:80"
}


output "db_address" {
  value = "${aws_db_instance.default.address}"
}
