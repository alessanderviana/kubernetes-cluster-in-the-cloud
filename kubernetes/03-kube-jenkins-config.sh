#!/usr/bin/env bash

# Create the namespace
kubectl create namespace cd-jenkins

# Create Jenkins persistence volume claim
kubectl create -f jenkins/jenkins-pv-path.yaml
kubectl create -f jenkins/jenkins-pv-claim.yaml

# Install Jenkins on kubernetes cluster
helm install --name jenkins stable/jenkins -f jenkins/jenkins-values.yaml --namespace cd-jenkins --wait

# Upgrade Jenkins chart
# helm upgrade jenkins stable/jenkins -f jenkins/jenkins-values.yaml --namespace cd-jenkins --wait

# Connect to Jenkins (get password)
if [ $? -eq 0 ]; then
  echo -e "\n########################################################################################################"
  printf $(kubectl get secret jenkins -n cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
  echo -e "########################################################################################################\n\n"
fi
