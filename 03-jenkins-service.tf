module "jenkins-service" {
  source = "git@github.com:TrackRbyPhoneHalo/it-fs-terraform-mod-microservice-ecs.git?ref=jenkins"

  service           = "jenkins"
  account_shorthand = "${var.account_shorthand}"
  environment       = "${var.environment}"
  project           = "${var.project}"
  owner             = "${var.owner}"
  expiration_date   = "${var.expiration_date}"
  monitor           = "${var.monitor}"
  cost_center       = "${var.cost_center}"

  cluster_name = "${module.ecs.name}"
  cluster_arn  = "${module.ecs.arn}"

  image = ""
  lb_target_group_arn = "${aws_alb_target_group.jenkins_http.arn}"

  service_cpu    = "1024"
  service_memory = "2048"

  service_host_port      = 8080
  service_container_port = 8080
  jenkis_agent_port      = 50000
}
