module "vpc" {
  source = "git::ssh://git@github.com/TrackRbyPhoneHalo/it-fs-terraform-mod-vpc.git"

  name                   = "${var.account_shorthand}-${var.environment}-VPC"
  cidr                   = "${var.vpc_cidr}"

  azs                    = ["${var.vpc_azs}"]
  private_subnets        = ["${var.vpc_private_subnets}"]
  public_subnets         = ["${var.vpc_public_subnets}"]

  enable_dns_hostnames   = "${var.vpc_enable_dns_hostnames}"

  enable_nat_gateway     = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway     = "${var.vpc_single_nat_gateway}"
  one_nat_gateway_per_az = "${var.vpc_one_nat_gateway_per_az}"

  tags = "${merge(local.vpc_tags, var.tags)}"
}

locals {
  vpc_tags = {
    Environment    = "${var.environment}"
    Project        = "${var.project}"
    Service        = "${var.service}"
    Owner          = "${var.owner}"
    ExpirationDate = "${var.expiration_date}"
    Monitor        = "${var.monitor}"
    CostCenter     = "${var.cost_center}"
    ManagedBy      = "Terraform"
  }
}
