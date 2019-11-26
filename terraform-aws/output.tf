output "private_ip_address" {
  value = [ "${aws_instance.k8s-aws.*.private_ip}" ]
}

output "public_ip_address" {
  value = [ "${aws_instance.k8s-aws.*.public_ip}" ]
}
