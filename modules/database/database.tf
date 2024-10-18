resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "my_terraform_db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = var.db_pass
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = var.db_sub_group_id
  vpc_security_group_ids = [var.sg_db_ter_id]
  tags = {
    Name = var.db_name
  }
}