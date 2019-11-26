provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s-aws" {
  ami                         = "ami-04b9e92b5572fa0d1"
  instance_type               = "t3.large"
  key_name                    = "devops-adm-virginia"
  subnet_id                   = "subnet-6912ae43"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.sg-k8s-aws.id}"]

  user_data     = <<SCRIPT
#!/bin/bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

echo "INSTALL DOCKER"
curl -fsSL https://get.docker.com/ | bash
usermod -aG docker ubuntu

echo "INSTALL KUBERNETES"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee -a /etc/apt/sources.list
apt-get update -q && apt-get install -y kubelet kubeadm kubectl

echo "CHANGING DOCKER DRIVER TO SYSTEMD"
cat > /etc/docker/daemon.json <<EOF
{
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-opts": {
   "max-size": "100m"
 },
 "storage-driver": "overlay2",
 "storage-opts": [
   "overlay2.override_kernel_check=true"
 ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload && systemctl restart docker

echo "DOWNLOADING NEEDED IMAGES"
kubeadm config images pull

echo "UPDATING O.S."
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef"
SCRIPT

tags = {
  Name        = "K8s AWS"
  Owner       = "SETS"
  Application = "K8s AWS Test"
  Environment = "Test"
}

}
