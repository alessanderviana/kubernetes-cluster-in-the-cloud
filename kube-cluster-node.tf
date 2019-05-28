
// Linux instance - Ubuntu 16.04
resource "google_compute_instance" "kube-cluster-node" {
 count = 2
 name         = "kube-cluster-node-${count.index + 1}"
 machine_type = "n1-standard-2"  # 7.5 GB RAM
 # machine_type = "n1-standard-1"  # 3.75 GB RAM
 zone         = "${var.region}-b"
 allow_stopping_for_update = true

 tags = [ "kube-cluster-node-${count.index + 1}" ]

 boot_disk {
   initialize_params {
     image = "ubuntu-1604-xenial-v20190306"
     size = 20
   }
 }

 network_interface {
   subnetwork = "default"
   access_config { }
   # If necessary update the firewall rule
   # *****************************************************************************************************
   # gcloud compute firewall-rules update YOUR_RULE_NAME --allow tcp:22,tcp:80,tcp:3389,tcp:8080,tcp:9000
   # *****************************************************************************************************
 }

 metadata {
   ssh-keys = "${var.user}:${file("${var.pub_key}")}"
 }

metadata_startup_script = "${file("startup-script.sh")}"

# sudo kubeadm init
# kubectl get pods -n kube-system
# kubeadm token create --print-join-command

# GutHub token
# 706272c8197b402d6e1d270a6be2ea08b1e9a1fd

}
