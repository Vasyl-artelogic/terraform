variable "sg_ports" {
  default = { http = "80", ssh = "22" }
  type        = map(string)
  description = "list of ingress ports"
}


variable "OIsniuk_ip" {
  default = "91.245.72.98/32"
  type        = string
  description = "OIsniuk's ip address"
}


variable "office_ip" {
  default = "91.200.115.220/32"
  type        = string
  description = "office ip address"
}

variable "my_home_ip" {
  default = "178.210.130.80/32"
  type        = string
  description = "my home ip address"
}


variable "ec2_ip" {
  type = string
  description = "The private ip of my ec2"  
}


variable "vpc_name" {
    type = string
}