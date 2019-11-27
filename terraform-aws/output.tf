output "private_ip_address" {
  value = aws_instance.k8s-master-aws.private_ip
}

output "public_ip_address" {
  value = aws_instance.k8s-master-aws.public_ip
}
