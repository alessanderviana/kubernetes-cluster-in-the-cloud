
resource "google_compute_instance" "kube-cluster-node" {
 count = 1
 name         = "kube-cluster-node-${count.index + 1}"
 # machine_type = "n1-standard-2"  # 7.5 GB RAM
 machine_type = "n1-standard-1"  # 3.75 GB RAM
 zone         = "${var.region}-b"
 allow_stopping_for_update = true

 tags = [ "kube-cluster-node-${count.index + 1}" ]

 boot_disk {
   initialize_params {
     image = "ubuntu-1804-bionic-v20190514"
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

}
