output "private_ip_address" {
  value = "${google_compute_instance.kube-cluster-master.network_interface.0.network_ip}"
}

output "public_ip_address" {
  value = "${google_compute_instance.kube-cluster-master.network_interface.0.access_config.0.nat_ip}"
}
