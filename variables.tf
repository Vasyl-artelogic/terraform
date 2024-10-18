variable "environment" {
    description = "Choose your environment: dev, test, prod or create your own"
    type = string
}


variable "db_user" {
    type = string
}

variable "db_pass" {
    type = string
}