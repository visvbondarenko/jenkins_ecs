#ALB
resource "aws_alb" "jenkins" {
  name                       = "${var.account_shorthand}-${var.environment}-${var.service}"
  internal                   = false
  security_groups            = ["${aws_security_group.jenkins_alb.id}"]
  subnets                    = ["${element(module.vpc.public_subnets, 0)}",
                                "${element(module.vpc.public_subnets, 1)}",
                                "${element(module.vpc.public_subnets, 2)}"]

  enable_deletion_protection = true

  tags {
    Account_shorthand = "${var.account_shorthand}"
    Name        = "${var.account_shorthand}_${var.environment}_${var.service}"
    Environment = "${var.environment}"
    Identifier  = "${var.account_shorthand}_${var.environment}_${var.service}"
    ManagedBy   = "terraform"
    Service     = "${var.service}"
  }
}

resource "aws_alb_listener" "jenkins" {
  load_balancer_arn = "${aws_alb.jenkins.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate_validation.jenkins_cert_validation.certificate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins_http.arn}"
    type             = "forward"
  }
}

resource "aws_acm_certificate" "jenkins" {
  domain_name       = "${var.alb_ssl_cert}"
  validation_method = "DNS"
}

data "aws_route53_zone" "domain_zone" {
  name         = "${var.domain_hosted_zone}"
  private_zone = false
}

resource "aws_route53_record" "jenkins_cert_validation" {
  name    = "${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.domain_zone.id}"
  records = ["${aws_acm_certificate.jenkins.domain_validation_options.0.resource_record_value}"]
  ttl = 300
}

resource "aws_acm_certificate_validation" "jenkins_cert_validation" {
  certificate_arn         = "${aws_acm_certificate.jenkins.arn}"
  validation_record_fqdns = ["${aws_route53_record.jenkins_cert_validation.fqdn}"]
}

###TG

resource "aws_alb_target_group" "jenkins_http" {
  name                 = "${var.account_shorthand}-${var.environment}-${var.service}"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = "60"

  stickiness {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = "86400"
  }

  health_check {
    interval            = "5"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "2"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    matcher             = "200"
  }

  tags {
    Account_shorthand = "${var.account_shorthand}"
    Name        = "${var.account_shorthand}_${var.environment}_${var.service}"
    Environment = "${var.environment}"
    Identifier  = "${var.account_shorthand}_${var.environment}_${var.service}"
    ManagedBy   = "terraform"
    Service     = "${var.service}"
    Owner       = ""
    Project     = ""
  }
}

###SG
# Security groups
resource "aws_security_group" "jenkins_alb" {
  name        = "${var.account_shorthand}_${var.environment}_${var.service}_alb"
  description = "Allow access to ${var.account_shorthand}_${var.environment}_${var.service} instance(s)"
  vpc_id      = "${module.vpc.vpc_id}"

  lifecycle {
    ignore_changes = [
      "description",
      "ami"]
  }

  tags {
    Account_shorthand = "${var.account_shorthand}"
    Environment = "${var.environment}"
    Name        = "${var.account_shorthand}_${var.environment}_${var.service}_alb"
    Identifier  = "${var.account_shorthand}_${var.environment}_${var.service}"
    ManagedBy   = "terraform"
    Service     = "${var.service}"
    Owner       = ""
    Project     = ""
  }
}

resource "aws_security_group_rule" "jenkins_https" {
  security_group_id = "${aws_security_group.jenkins_alb.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_egress_alb" {
  security_group_id = "${aws_security_group.jenkins_alb.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"

  cidr_blocks       = ["0.0.0.0/0"]
}
