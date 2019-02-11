resource "aws_s3_bucket" "build-bucket" {
  bucket = "codebuild-${var.project_name}"
  acl    = "private"
}

resource "aws_s3_bucket" "deploy-bucket" {
  bucket = "${var.deploy_s3_bucket}"
  acl    = "private"
}
