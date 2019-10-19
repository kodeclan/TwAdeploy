// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 4
}

resource "null_resource" "keygen" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.keydir}"
  }

  provisioner "local-exec" {
    command = "yes y | ssh-keygen -t rsa -b 4096 -N '' -C 'Key for username: ${var.username}' -f '${local.keyfile_pvt}' > '${local.keyfile_pvt}.out'"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${local.keyfile_pvt} ${local.keyfile_pvt}.out ${local.keyfile_pub}"
  }
}

resource "google_compute_firewall" "default_firewall" {
  name    = "tf-ssh-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["external-ssh"]
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "htsquirrel" {
  count    = var.instances
  provider = google

  name         = "htsquirrel-vm-${local.instance_id}-${count.index}"
  machine_type = "f1-micro"
  zone         = "us-east4-c"

  tags = ["external-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Run the bootstrapper
  metadata_startup_script = file("bootstrap.sh")

  // Metadata: We use this to set the SSH keys
  metadata = {
    ssh-keys = "${var.username}:${file(local.keyfile_pub)}"
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  provisioner "remote-exec" {
    inline = [
      "echo Hello world, we have connected to the instance",
    ]

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.username
      private_key = file(local.keyfile_pvt)
    }
  }

  depends_on = [google_compute_firewall.default_firewall, null_resource.keygen]
}
