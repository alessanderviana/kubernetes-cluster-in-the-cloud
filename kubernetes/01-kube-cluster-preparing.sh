#!/usr/bin/env bash

# Cluster init
kubeadm init

# Configure the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Create the wave-net pod
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Bash completion
echo "source <(kubectl completion bash)" >> .bashrc

# Print Master token
echo -e "\n########################################################################################################"
kubeadm token create --print-join-command
echo -e "########################################################################################################\n\n"
