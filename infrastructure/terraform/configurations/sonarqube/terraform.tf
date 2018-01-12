terraform {
  backend "s3" {
    bucket  = "project-spike"
    key     = "project-sonarqube"
    region  = "eu-west-2"
    encrypt = true
  }
}
