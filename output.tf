output "s3_bucket_dns" {
  value = "${module.codepipeline.cloudfront_dns}"
}
