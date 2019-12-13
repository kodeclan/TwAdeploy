variable "project" {
  type        = string
  description = "The name of the project as available in Google Cloud Platform Console."
}

variable "credentials" {
  type        = string
  description = "The filename of the json file that contains the service account key.\nIt can be obtained at: https://console.cloud.google.com/apis/credentials/serviceaccountkey"
}

variable "username" {
  type        = string
  default     = "ansible"
  description = "The username that will be used to connect to the GCP instance via SSH."
}

variable "machine_name" {
  type        = string
  default     = "twain"
  description = "The name prefix to be used for the VM instances. Useful in distinguishing and categorizing the machines."
}

variable "keydir" {
  type        = string
  default     = ".keys"
  description = "The local directory where the SSH keys will be stored."
}

variable "inventory_file" {
  type        = string
  default     = "inventory.ansible"
  description = "The name of the inventory file that will be used by ansible"
}

variable "playbook_file" {
  type        = string
  default     = "playbook.yml"
  description = "The name of the ansible playbook that will be executed once the instances are created"
}

variable "instances" {
  type        = string
  default     = 1
  description = "The number of instances to spawn"
}

locals {
  instance_id   = random_id.instance_id.hex
  all_instances = google_compute_instance.twa[*].id
  instance_ips  = google_compute_instance.twa[*].network_interface.0.access_config.0.nat_ip
  keyfile_pvt   = "${var.keydir}/${local.instance_id}"
  keyfile_pub   = "${var.keydir}/${local.instance_id}.pub"
}

// A variable for extracting the external ip of the instance
output "ip" {
  value = google_compute_instance.twa[*].network_interface.0.access_config.0.nat_ip
}

