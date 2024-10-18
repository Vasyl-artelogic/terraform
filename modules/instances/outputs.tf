output "instance_public_ip" {
  value = aws_instance.my_first_ter_ec2.public_ip
}

output "private_ip" {
  value = aws_instance.my_first_ter_ec2.private_ip 
}