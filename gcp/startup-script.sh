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

# Run the playbook
ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/node-install-software.yml

# If it's the node 1, Initialize the cluster
if [[ "$HOSTNAME" == *"node-1"* ]]; then
  echo -e "[kube-master]\n127.0.0.1 ansible_connection=local\n" | sudo tee -a /etc/ansible/hosts
  ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kube-setup-cluster.yml
fi

# Activate the service account
gcloud auth activate-service-account \
  kubernetes-svc@infra-como-codigo-e-automacao.iam.gserviceaccount.com \
  --key-file=/home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kubernetes-svc.json

# Get the kubernetes nodes
NODE_IPS=$( gcloud compute instances list --filter="(name~kube-cluster-node-[2-9] AND zone:us-central1-b)" --format="value(name,networkInterfaces[0].networkIP)" | awk '{ print $2 }' )
echo -e "[kube-nodes]\n$NODE_IPS\n" | sudo tee -a /etc/ansible/hosts
