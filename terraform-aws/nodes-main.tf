resource "aws_instance" "k8s-nodes-aws" {
  ami                         = "ami-04b9e92b5572fa0d1"
  instance_type               = "t3.medium"
  key_name                    = "devops-adm-virginia"
  subnet_id                   = "subnet-6912ae43"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.sg-k8s-aws.id}"]
  count                       = 2

  user_data = "${file("startup-script.sh")}"

  tags = {
    Name        = "K8s AWS - Node${count.index + 1}"
    Owner       = "SETS"
    Application = "K8s AWS Test"
    Environment = "Test"
  }

}
