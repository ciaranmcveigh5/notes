terraform {
  backend "s3" {
    bucket  = "project-spike"
    key     = "project-core"
    region  = "eu-west-2"
    encrypt = true
  }
}
