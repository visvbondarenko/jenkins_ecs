module "bastion" {
  source = "git@github.com:TrackRbyPhoneHalo/it-fs-terraform-mod-bastion.git?ref=master"

  lookup_latest_ami = true

  account_shorthand = "${var.account_shorthand}"
  environment       = "${var.environment}"
  project           = "${var.project}"
  service           = "${var.service}"
  owner             = "${var.owner}"
  expiration_date   = "${var.expiration_date}"
  monitor           = "${var.monitor}"
  cost_center       = "${var.cost_center}"

  key_name = "${aws_key_pair.bastion_host_key.key_name}"

  tags = "${var.tags}"

  azs     = [ "${var.vpc_azs}" ]
  subnets = [ "${module.vpc.public_subnets}" ]
  vpc_id  = "${module.vpc.vpc_id}"
}

# bastion ssh keys
data "aws_secretsmanager_secret" "bastion_host_key" {
  name = "${lower("${var.account_shorthand}/${var.environment}/gerrit/bastion/ssh")}"
}

resource "aws_secretsmanager_secret_version" "bastion_host_key" {
  secret_id     = "${data.aws_secretsmanager_secret.bastion_host_key.id}"
  secret_string = "${jsonencode(map(
    "private_key", "${tls_private_key.bastion_host_key.private_key_pem}",
    "public_key", "${tls_private_key.bastion_host_key.public_key_openssh}"
  ))}"
}

resource "tls_private_key" "bastion_host_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "bastion_host_key" {
  key_name   = "${var.environment}-${var.service}-BastionHostKey"
  public_key = "${tls_private_key.bastion_host_key.public_key_openssh}"
}
