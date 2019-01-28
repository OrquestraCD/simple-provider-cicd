resource "aws_iam_role" "codebuild-role" {
  name = "codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-role-policy" {
  role = "${aws_iam_role.codebuild-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.build-bucket.arn}",
        "${aws_s3_bucket.build-bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "simple-cicd" {
  name          = "simple-cicd-${var.project_name}"
  description   = "Simple CICD build for ${var.project_name}"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.codebuild__image}"
    type         = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"

    buildspec = <<BUILDSPEC
version: 0.2

environment_variables:
  plaintext:
    PACKAGE: "${var.go_package}"

phases:
  install:
    commands:
      - echo CODEBUILD_SRC_DIR - $$CODEBUILD_SRC_DIR
      - echo GOPATH - $$GOPATH

      - echo Create dir in GOPATH for sources
      - mkdir -p /go/src/$${PACKAGE}

      - echo Copy source files into GOPATH
      - echo cp -a $${CODEBUILD_SRC_DIR}/.  /go/src/$${PACKAGE}
      - cp -a $${CODEBUILD_SRC_DIR}/.  /go/src/$${PACKAGE}

      - cd /go/src/$${PACKAGE} && go get ./...

  build:
    commands:
      - cd /go/src/$${PACKAGE} && env GOOS=darwin GOARCH=amd64 go build -o $${CODEBUILD_SRC_DIR}/output/darwin_amd64/${var.github__repo}
      - cd /go/src/$${PACKAGE} && md5sum $${CODEBUILD_SRC_DIR}/output/darwin_amd64/${var.github__repo} > $${CODEBUILD_SRC_DIR}/output/darwin_amd64/${var.github__repo}.md5sum

      - cd /go/src/$${PACKAGE} && env GOOS=linux GOARCH=amd64 go build -o $${CODEBUILD_SRC_DIR}/output/linux_amd64/${var.github__repo}
      - cd /go/src/$${PACKAGE} && md5sum $${CODEBUILD_SRC_DIR}/output/linux_amd64/${var.github__repo} > $${CODEBUILD_SRC_DIR}/output/linux_amd64/${var.github__repo}.md5sum
  post_build:
    commands:

artifacts:
  files:
    - '**/*'
  base-directory: output
BUILDSPEC
  }

  tags = "${var.tags}"
}
