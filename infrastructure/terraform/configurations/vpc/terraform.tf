terraform {
  backend "s3" {
    bucket  = "project-spike"
    key     = "project-vpc"
    region  = "eu-west-2"
    encrypt = true
  }
}
