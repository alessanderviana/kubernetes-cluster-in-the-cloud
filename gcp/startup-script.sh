#!/usr/bin/env bash

# Fix Locale and adjust Timezone
locale-gen pt_BR.UTF-8 && \
rm -f /etc/localtime && sudo ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Ansible
apt-get update -q
apt-get install -y software-properties-common

apt-add-repository -y ppa:ansible/ansible

apt-get update -q
apt-get install -y ansible

# Clone the REPO
sudo -u ubuntu git clone https://github.com/alessanderviana/kubernetes-cluster-in-the-cloud.git

# Run the playbook
ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/node-install-software.yml

# # Adjust Docker driver (change to systemd)
# cat > /etc/docker/daemon.json <<EOF
# {
#  "exec-opts": ["native.cgroupdriver=systemd"],
#  "log-driver": "json-file",
#  "log-opts": {
#    "max-size": "100m"
#  },
#  "storage-driver": "overlay2",
#  "storage-opts": [
#    "overlay2.override_kernel_check=true"
#  ]
# }
# EOF
# mkdir -p /etc/systemd/system/docker.service.d
# systemctl daemon-reload && systemctl restart docker
#
# # Needed kubernetes images
# kubeadm config images pull
