
resource "google_compute_instance" "kube-cluster-master" {
 name         = "kube-cluster-master"
 machine_type = "n1-standard-2"  # 7.5 GB RAM
 zone         = "${var.region}-b"
 allow_stopping_for_update = true

 labels = {
    name = "kube-cluster-master"
  }

 boot_disk {
   initialize_params {
     image = "ubuntu-1804-bionic-v20191113" # ubuntu-1604-xenial-v20190514
     size = 50
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
