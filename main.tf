locals {
  tags = {
    Project = "${var.project_name}"
  }
}

module "codepipeline" {
  source = "./modules/codepipeline"

  github__owner    = "${var.github__owner}"
  github__repo     = "${var.github__repo}"
  github__branch   = "${var.github__branch}"
  project_name     = "${var.project_name}"
  deploy_s3_bucket = "${var.s3_bucket}"
  go_package       = "${var.go_package}"

  tags = "${local.tags}"
}
