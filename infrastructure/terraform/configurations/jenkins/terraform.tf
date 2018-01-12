terraform {
  backend "s3" {
    bucket  = "project-spike"
    key     = "project-jenkins"
    region  = "eu-west-2"
    encrypt = true
  }
}
