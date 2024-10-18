locals {
  env_suffix = terraform.workspace
  base_name = "artelogic_project"

  resource_names = {
    vpc = "${local.base_name}-vpc-${local.env_suffix}"
    instance = "${local.base_name}-instance-${local.env_suffix}"
    db = "${local.base_name}-db-${local.env_suffix}"
  }
}


module "networking" {
    source = "./modules/networking/"
    ec2_ip = module.instances.private_ip
    vpc_name = local.resource_names.vpc

}


module "instances" {
    source = "./modules/instances/"
    subnet_id = module.networking.subnet_tf_id
    sg_ter_id = module.networking.sg_group
    instance_name = local.resource_names.instance
}


module "database" {
    source = "./modules/database/"
    db_user = var.db_user
    db_pass = var.db_pass
    db_sub_group_id = module.networking.db_sub_group_id
    sg_db_ter_id = module.networking.sg_db_ter_id
    db_name = local.resource_names.db
}