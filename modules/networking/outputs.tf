output "db_sub_group_id" {
  value = aws_db_subnet_group.my_ter_db_sub_gr.id
}

output "sg_db_ter_id" {
  value = aws_security_group.sg-db-ter.id
}

output "subnet_tf_id" {
  value = aws_subnet.my-tf-subnet.id
}

output "sg_group" {
  value = aws_security_group.sg-ter.id
}