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
cd /home/ubuntu && sudo -u ubuntu git clone https://github.com/alessanderviana/kubernetes-cluster-in-the-cloud.git

# Run the playbook
ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/node-install-software.yml

# If it's the node 1, Initialize the cluster
if [[ "$HOSTNAME" == *"node-1"* ]]; then
  sed -i 's/<hostname>/${HOSTNAME}/g' /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kube-setup-cluster.yml
  ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kube-setup-cluster.yml
fi
