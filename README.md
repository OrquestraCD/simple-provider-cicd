# simple-provider-cicd

A simple Terraform module to setup a CICD CodePipeline from Github to S3. This is specifically meant to build Terraform providers that are either branches or forks of the existing providers, so you can have access to new features before the merged into the 'master'.

Right now there are a lot of forks and branches of the main Terraform providers that include features not yet accepted into the 'master' branch via PR. However, that doesn't mean you couldn't use them! You'd just need to clone and build, but if you are unfamiliar with GOLANG that's not an easy learning curve. Getting a build setup of the Provider is likely outside the skillset of many Terraform users, so this project aims to take all the heavy thinking of getting GOLANG projects built.

# What you get

This will produce the basic AWS setup described on the blog. Specifically, it will pull from a Github repo of your
choosing. If you are pointing this at a private repository, make sure to setup an OAuth Token in your GITHUB_TOKEN environment variable before your `terraform apply`:

```bash
$ export GITHUB_TOKEN=...
```

It will build that project using a GOLANG 1.11 CodeBuild project setup to build GOLANG providers.

CodePipeline will then deploy the artifacts to an S3 bucket. 

# How to use

This is meant to be imported as a module in your own Terraform templates:

```terraform
module "codepipeline" {
  source = "github.com/rackerlabs/simple-provider-cicd?ref=master"

  github__owner  = "terraform-providers"
  github__repo   = "terraform-provider-aws"
  github__branch = "master"
  project_name   = "standard-aws-provider"
  s3_bucket      = "terraform-provider-aws-mycustombucket"
  go_package     = "github.com/terraform-providers/terraform-provider-aws"    
}
```

However, you could also just clone this repo and `tf init && tf apply`, I can't stop you.

Once complete, the output of the module, `s3_bucket_dns` will point you to where your resulting provider is built. 

Download the resulting artifact (it's public by default) and install it into your local plugins directory:

```bash

$ mkdir -p ~/.terraform/plugins/
$ curl -o ~/.terraform/plugins/terraform-provider-aws https://terraform-provider-aws-mycustombucket.s3.amazonaws.com/linux_amd64/terraform-provider-aws

```
Notice: the example is specifically getting the "linux_amd64" build. If you are on MacOS, use the "darwin_amd64" build instead.

Note: Right now only linux_amd64 and darwin_amd64 files are produced. If you need others (like Windows), either modify this TF module yourself (the `codebuild.tf` file) or [open an issue](https://github.com/rackerlabs/simple-provider-cicd/issues)

There is an md5sum file that is also produced during the build process. I recommend you checksum your downloaded file provider against this checksum.

# Feedback

If you have feedback, either problems or requests or questions, please submit an [Issue](https://github.com/rackerlabs/simple-provider-cicd/issues).


