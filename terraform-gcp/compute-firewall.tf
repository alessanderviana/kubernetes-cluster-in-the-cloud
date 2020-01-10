resource "google_compute_firewall" "ssh-k8s-aws" {
  name        = "ssh-k8s-aws"
  description = "Compute Firewall K8s AWS"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # target_tags   = "default"
  source_ranges = ["10.63.116.0/23","10.63.114.0/23","10.63.164.0/24","10.63.14.0/24","185.125.225.22/32"]
}

resource "google_compute_firewall" "internal-k8s-aws" {
  name        = "internal-k8s-aws"
  description = "Compute Firewall K8s AWS"
  network = "default"

  allow {
    protocol      = "tcp"
    ports         = ["0-65535"]
  }

  # target_tags   = "default"
  source_ranges = ["10.128.0.0/20"]
}

resource "google_compute_firewall" "kube-k8s-aws" {
  name        = "kube-k8s-aws"
  description = "Compute Firewall K8s Kubernetes services"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["6443","80","443"]
  }

  # target_tags   = "default"
  source_ranges = ["10.63.116.0/23","10.63.114.0/23","10.63.164.0/24","10.63.14.0/24","185.125.225.22/32"]
}
