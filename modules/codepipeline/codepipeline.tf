resource "aws_codepipeline" "codepipeline" {
  artifact_store {
    location = "${aws_s3_bucket.build-bucket.bucket}"
    type     = "S3"
  }

  role_arn = "${aws_iam_role.simple-codepipeline-role.arn}"
  name     = "simple-provider-${var.project_name}"

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "ThirdParty"
      provider = "GitHub"
      version  = "1"

      output_artifacts = [
        "build",
      ]

      configuration {
        Owner  = "${var.github__owner}"
        Repo   = "${var.github__repo}"
        Branch = "${var.github__branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"

      input_artifacts = [
        "build",
      ]

      output_artifacts = ["deployables"]

      version = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.simple-cicd.name}"
      }
    }
  }

  stage = {
    name = "Deploy"

    action {
      name     = "Deploy"
      owner    = "AWS"
      provider = "S3"
      version  = "1"
      category = "Deploy"

      input_artifacts = [
        "deployables",
      ]

      configuration {
        BucketName = "${aws_s3_bucket.deploy-bucket.bucket}"
        Extract    = "true"
      }
    }
  }
}

resource "aws_iam_role" "simple-codepipeline-role" {
  name = "simple-codepipeline-role-${var.project_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.simple-codepipeline-role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${var.deploy_s3_bucket}/*"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "${aws_codebuild_project.simple-cicd.arn}",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "${aws_s3_bucket.build-bucket.arn}/*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}
