variable "region" {
  default = "us-central1"
}
variable "gcp_project" {
  default = "jeyloo-185311"  # infra-como-codigo-e-automacao"
}
variable "credentials" {
  default = "~/.ssh/jeyloo-185311-e3f2f99780ea.json"
}
variable "vpc_name" {
  default = "default"
}
variable "user" {
  default = "ubuntu"
}
variable "pub_key" {
  default = "~/.ssh/google_compute_engine.pub"
}
variable "priv_key" {
  default = "~/.ssh/google_compute_engine"
}
