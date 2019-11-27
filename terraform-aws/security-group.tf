resource "aws_security_group" "sg-k8s-aws" {
  name        = "k8s-aws"
  description = "SG K8s AWS"
  vpc_id      = "${var.vpc_somos}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.63.116.0/23","10.63.114.0/23","10.63.164.0/24","10.63.14.0/24","187.20.141.156/32"]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["10.63.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
