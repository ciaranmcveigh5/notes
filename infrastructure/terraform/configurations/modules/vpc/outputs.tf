output "project_vpc" {
  value = "${aws_vpc.project.id}"
}

output "project_public_subnet" {
  value = "${aws_subnet.public_a.id}"
}

output "project_public_subnet_b" {
  value = "${aws_subnet.public_b.id}"
}

output "project_private_subnet" {
  value = "${aws_subnet.private_a.id}"
}
