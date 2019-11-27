resource "aws_instance" "k8s-master-aws" {
  ami                         = "ami-04b9e92b5572fa0d1"
  instance_type               = "t3.large"
  key_name                    = "devops-adm-virginia"
  subnet_id                   = "subnet-6912ae43"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.sg-k8s-aws.id}"]

  user_data = "${file("startup-script.sh")}"

  tags = {
    Name        = "K8s AWS - Master"
    Owner       = "SETS"
    Application = "K8s AWS Test"
    Environment = "Test"
  }

}
