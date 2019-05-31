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

# Enable SSH root login and with password
sed -i 's/#\ \ \ PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/ssh_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# root password
passwd <<EOF
kub3_+eRra 4nS1ble
kub3_+eRra 4nS1ble
EOF

# Generate a key pair to root
ssh-keygen -t rsa -f ~/.ssh/kube_${USER} -q -N ""

# Run the playbook
ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/node-install-software.yml

# If it's the node 1, Initialize the cluster
if [[ "$HOSTNAME" == *"node-1"* ]]; then
  sed -i 's/#host_key_checking/host_key_checking/g' /etc/ansible/ansible.cfg
  echo -e "[kubemaster]\n127.0.0.1 ansible_connection=local\n" | sudo tee -a /etc/ansible/hosts
  echo -e "[kubemaster:vars]\nansible_python_interpreter=/usr/bin/python3\n" | sudo tee -a /etc/ansible/hosts
  ansible-playbook /home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kube-setup-cluster.yml
fi

# Activate the service account
gcloud auth activate-service-account \
  kubernetes-svc@infra-como-codigo-e-automacao.iam.gserviceaccount.com \
  --key-file=/home/ubuntu/kubernetes-cluster-in-the-cloud/ansible/kubernetes-svc.json

# Get the kubernetes nodes
NODE_IPS=$( gcloud compute instances list --filter="(name~kube-cluster-node-[2-9] AND zone:us-central1-b)" --format="value(name,networkInterfaces[0].networkIP)" | awk '{ print $2 }' )
echo -e "[kubenodes]\n$NODE_IPS\n" | sudo tee -a /etc/ansible/hosts
echo -e "[kubenodes:vars]\nansible_python_interpreter=/usr/bin/python3\n" | sudo tee -a /etc/ansible/hosts

# Join the nodes to cluster
if [[ "$HOSTNAME" == *"node-1"* ]]; then
  JOIN_COMMAND=$( kubeadm token create --print-join-command )
  ansible kubenodes -m shell -a '${JOIN_COMMAND}' --private-key ~/.ssh/kube_${USER}
fi
