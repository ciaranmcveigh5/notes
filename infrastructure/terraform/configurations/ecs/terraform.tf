terraform {
  backend "s3" {
    bucket  = "project-spike"
    key     = "project-ecs"
    region  = "eu-west-2"
    encrypt = true
  }
}
