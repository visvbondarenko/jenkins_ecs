variable "account_shorthand"          {}
variable "environment"                {}
variable "project"                    {}
variable "service"                    {}
variable "owner"                      {}
variable "expiration_date"            {}
variable "monitor"                    {}
variable "cost_center"                {}

variable "vpc_cidr"                   {}
variable "vpc_azs"                    { type = "list" }
variable "vpc_private_subnets"        { type = "list" }
variable "vpc_public_subnets"         { type = "list" }
variable "vpc_enable_dns_hostnames"   { default = true }
variable "vpc_enable_nat_gateway"     { default = true }
variable "vpc_single_nat_gateway"     { default = false }
variable "vpc_one_nat_gateway_per_az" { default = true }
variable "vpc_monitor"                { default = 0 }
variable "regions_azs"                { type = "map" default = {"us-east-1" = ["us-east-1a", "us-east-1b", "us-east-1c"]}}

variable "tags"       { type = "map" }
variable "aws_region" {}

variable "ecs_monitor"            { default = 0 }
variable "ecs_min_size"           { default = 1 }
variable "ecs_max_size"           { default = 10 }
variable "ecs_desired_size"       { default = 1 }
variable "ecs_instance_type"      { default = "t2.micro" }
variable "ecs_instance_root_size" { default = 10 }
variable "ecs_enable_ssh"         { default = false }

variable "domain_hosted_zone" {}
variable "dns_alias"          { default = "jenkins" }
variable "alb_ssl_cert"       {}
variable "private_dns_zone"   { default = false }