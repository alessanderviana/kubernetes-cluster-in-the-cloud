#!/usr/bin/env bash

# Clone the REPO
cd /root && git clone https://github.com/alessanderviana/kubernetes-cluster-in-the-cloud.git

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

# In GCP we have to disable the sshguard
systemctl stop sshguard
systemctl disable sshguard

# root password
PASS='kub3_+eRra 4nS1ble'
passwd <<EOF
${PASS}
${PASS}
EOF

# Run the playbook
ansible-playbook kubernetes-cluster-in-the-cloud/ansible/node-install-software.yml

# If it's the node 1, do the specified below
if [[ "$HOSTNAME" == *"node-1"* ]]; then
  # Initialize the cluster
  sed -i 's/#host_key_checking/host_key_checking/g' /etc/ansible/ansible.cfg
  echo -e "[kubemaster]\n127.0.0.1 ansible_connection=local\n" | sudo tee -a /etc/ansible/hosts
  echo -e "[kubemaster:vars]\nansible_python_interpreter=/usr/bin/python3\n" | sudo tee -a /etc/ansible/hosts
  ansible-playbook kubernetes-cluster-in-the-cloud/ansible/kube-setup-cluster.yml

  # Activate the service account
  gcloud auth activate-service-account \
    kubernetes-svc@infra-como-codigo-e-automacao.iam.gserviceaccount.com \
    --key-file=kubernetes-cluster-in-the-cloud/ansible/kubernetes-svc.json

  # Get the kubernetes nodes
  NODE_IPS=$( gcloud compute instances list --filter="(name~kube-cluster-node-[2-9] AND zone:us-central1-b)" --format="value(name,networkInterfaces[0].networkIP)" | awk '{ print $2 }' )
  echo -e "[kubenodes]\n$NODE_IPS\n" | sudo tee -a /etc/ansible/hosts
  echo -e "[kubenodes:vars]\nansible_python_interpreter=/usr/bin/python3\n" | sudo tee -a /etc/ansible/hosts

  # Generate a key pair to root
  ssh-keygen -t rsa -f /root/.ssh/kube_root -q -N ""

  # Get the nodes
  NODE_HOSTS=$( ansible kubenodes -i /etc/ansible/hosts --list-hosts | grep -v hosts )

  for H in $( echo $NODE_HOSTS );
  do
    sshpass -p "${PASS}" ssh-copy-id -i .ssh/kube_root ${H}
  done

  # Join the nodes to cluster
  JOIN_COMMAND=$( kubeadm token create --print-join-command )
  ansible kubenodes -m shell -a '${JOIN_COMMAND}' --private-key=/root/.ssh/kube_root
fi

# tail -f /var/log/syslog | grep startup-script
