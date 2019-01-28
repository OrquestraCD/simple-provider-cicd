variable "project_name" {
  type = "string"
}

variable "github__owner" {
  type = "string"
}

variable "github__repo" {
  type = "string"
}

variable "github__branch" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "deploy_s3_bucket" {
  type = "string"
}

variable "codebuild__image" {
  default = "aws/codebuild/golang:1.11"
}

variable "go_package" {
  description = "This will get used to declare the GOLANG package to build"
}
