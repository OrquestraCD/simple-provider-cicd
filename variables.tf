variable "project_name" {
  type        = "string"
  description = "A unique name that gets used in Tags and some identifiers "
}

variable "github__owner" {
  type        = "string"
  description = "The owner username of the Github repository"
}

variable "github__repo" {
  type        = "string"
  description = "The repository name in Github"
}

variable "github__branch" {
  type        = "string"
  default     = "master"
  description = "The branch of the repository to build"
}

variable "s3_bucket" {
  type        = "string"
  description = "The S3 bucket where the built provider will be stored."
}

variable "codebuild__image" {
  default     = "aws/codebuild/golang:1.11"
  description = "The CodeBuild image to use for building the provider."
}

variable "go_package" {
  type = "string"
}

