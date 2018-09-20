module "ecs" {
  source = "./modules/it-fs-terraform-mod-ecs"

  account_prefix    = "${var.account_shorthand}"

  environment     = "${var.environment}"
  project         = "${var.project}"
  service         = "${var.service}"
  owner           = "${var.owner}"
  expiration_date = "${var.expiration_date}"
  monitor         = "${var.ecs_monitor}"
  cost_center     = "${var.cost_center}"
  extra_tags      = "${var.tags}"

  vpc_id            = "${module.vpc.vpc_id}"
  lookup_latest_ami = true
  instance_type     = "${var.ecs_instance_type}"

  key_name             = "${var.ecs_enable_ssh ? aws_key_pair.ecs_host_key.key_name : ""}"

  private_subnet_ids = [ "${module.vpc.private_subnets}" ]

  root_block_device_type = "gp2"
  root_block_device_size = "${var.ecs_instance_root_size}"

  health_check_grace_period = "600"
  desired_capacity          = "${var.ecs_desired_size}"
  min_size                  = "${var.ecs_min_size}"
  max_size                  = "${var.ecs_max_size}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

data "aws_secretsmanager_secret" "ecs_host_key" {
  name = "${lower(var.environment)}/ecs/ssh"
}

resource "aws_secretsmanager_secret_version" "ecs_host_key" {
  secret_id     = "${data.aws_secretsmanager_secret.ecs_host_key.id}"
  secret_string = "${jsonencode(map("private_key", "${tls_private_key.key.private_key_pem}", "public_key", "${tls_private_key.key.public_key_openssh}"))}"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ecs_host_key" {
  key_name   = "${var.environment}-${var.service}-EcsContainerHostKey"
  public_key = "${tls_private_key.key.public_key_openssh}"
}

resource "aws_security_group_rule" "ingress_allow_all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [ "0.0.0.0/0" ]

  security_group_id = "${module.ecs.container_instance_security_group_id}"
}

data "aws_route53_zone" "zone" {
  name         = "${var.domain_hosted_zone}"
  private_zone = "${var.private_dns_zone}"
}

resource "aws_route53_record" "gerrit" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.dns_alias}"
  type    = "A"

  alias {
    name                   = "${aws_alb.jenkins.dns_name}"
    zone_id                = "${aws_alb.jenkins.zone_id}"
    evaluate_target_health = true
  }
}
