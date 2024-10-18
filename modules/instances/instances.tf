data "aws_ami" "check_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  #description : for check latest versions of  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server
}


resource "aws_instance" "my_first_ter_ec2" {

  ami = data.aws_ami.check_ami.image_id
  #description : it's check data wich ami is latest
  instance_type               = "t2.micro"
  key_name                    = "key_to_ec2_1st_task"
  availability_zone           = "eu-central-1a"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [var.sg_ter_id]
  lifecycle {
    ignore_changes = [ tags ]
  }
  tags = {
    Name = var.instance_name
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/Desktop/terraform/terraform-key.pem")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt update && sudo apt install mysql-server -y && sudo apt install nginx -y"
    ]
    
  }
}