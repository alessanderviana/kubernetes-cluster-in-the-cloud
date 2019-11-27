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
