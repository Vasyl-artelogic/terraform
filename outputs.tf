output "public_ip" {
    value = module.instances.instance_public_ip
}

output "private_db_dns" {
    value = module.database.db_dns_name
}
