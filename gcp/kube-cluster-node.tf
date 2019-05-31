
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
     image = "ubuntu-1604-xenial-v20190514"
     size = 20
   }
 }

 network_interface {
   subnetwork = "default"
   access_config { }
 }

 metadata {
   ssh-keys = "${var.user}:${file("${var.pub_key}")}"
 }

 provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "${var.user}"
      private_key = "${file("${var.priv_key}")}"
      agent = false
    }

    inline = [
      <<SCRIPT
      sudo su - && \
      cd && \
      git clone https://github.com/alessanderviana/kubernetes-cluster-in-the-cloud.git && \
      bash /home/ubuntu/kubernetes-cluster-in-the-cloud/gcp/startup-script.sh
SCRIPT
      ,
    ]
 }

}
