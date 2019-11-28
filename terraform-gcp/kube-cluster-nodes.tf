
resource "google_compute_instance" "kube-cluster-node" {
 count        = 1
 name         = "kube-cluster-node-${count.index + 1}"
 machine_type = "n1-standard-1"  # 3.75 GB RAM
 zone         = "${var.region}-b"
 allow_stopping_for_update = true

 tags = [ "Kube Cluster Node 1" ]

 boot_disk {
   initialize_params {
     image = "ubuntu-1804-bionic-v20191113"
     size = 20
   }
 }

 network_interface {
   subnetwork = "default"
   access_config { }
 }

 metadata = {
   ssh-keys = "${var.user}:${file("${var.pub_key}")}"
 }

metadata_startup_script = "${file("startup-script.sh")}"

}
