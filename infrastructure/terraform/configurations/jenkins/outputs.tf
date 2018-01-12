output "jenkins_key" {
  value = "${aws_key_pair.jenkins_key.key_name}"
}

output "jenkins_iam" {
  value = "${aws_iam_role.jenkins_admin.arn}"
}
