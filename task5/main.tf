provider "aws" {
    region = "us-east-1" 
} 



terraform {
  backend "s3" {
    bucket         = "task51"
    key            = "task5/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformStateLocks"
  }
}


module "my-network"{
    source = "./modules/network"
}


module "my-server"{
    source                 = "./modules/webserver"
    ami                    =  "ami-03774a014f08a0d8d"
    subnet_id              = module.my-network.public_subnet_1_id
    instance_type          = "t2.micro"
    security_group_vpc_id  = module.my-network.vpc_id

}

module "asg-alb"{
    source = "./modules/asg_alb"
    aws_launch_configuration_security_group = [module.my-server.security_group_id]
    aws_launch_configuration_instance_type  = "t2.micro"
    aws_launch_configuration_image_id  = "ami-03774a014f08a0d8d"
    aws_autoscaling_group_vpc_zone_identifier = [module.my-network.public_subnet_1_id, module.my-network.public_subnet_2_id]
    aws_lb_subnet_mapping_1 = module.my-network.public_subnet_1_id
    aws_lb_subnet_mapping_2 = module.my-network.public_subnet_2_id
    vpc_id = module.my-network.vpc_id 
    aws_lb_target_group_attachment_target_id  = module.my-server.instance_id

}
