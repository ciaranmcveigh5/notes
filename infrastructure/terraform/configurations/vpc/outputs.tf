output "project_vpc" {
  value = "${module.vpc.project_vpc}"
}

output "project_public_subnet" {
  value = "${module.vpc.project_public_subnet}"
}

output "project_public_subnet_b" {
  value = "${module.vpc.project_public_subnet_b}"
}

output "project_private_subnet" {
  value = "${module.vpc.project_private_subnet}"
}

output "project_base_sg" {
  value = "${aws_security_group.project_base.id}"
}

output "project_zone_id" {
  value = "${data.aws_route53_zone.core.id}"
}

output "project_zone_name" {
  value = "${data.aws_route53_zone.core.name}"
}
