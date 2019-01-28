resource "aws_s3_bucket" "build-bucket" {
  bucket = "codebuild-${var.project_name}"
  acl    = "private"
}

resource "aws_s3_bucket" "deploy-bucket" {
  bucket = "${var.deploy_s3_bucket}"
  acl    = "private"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "Policy1548346025552",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.deploy_s3_bucket}/*"
        }
    ]
}
EOF
}
