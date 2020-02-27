// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 4
}

resource "random_id" "firewall_id" {
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
    when    = destroy
    command = "rm ${local.keyfile_pvt} ${local.keyfile_pvt}.out ${local.keyfile_pub}"
  }
}

resource "google_compute_firewall" "default_firewall" {
  name    = "tf-ssh-firewall-${local.firewall_id}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["external-ssh"]
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "twa" {
  count    = var.instances
  provider = google

  name         = "${var.machine_name}-vm-${local.instance_id}-${count.index}"
  machine_type = var.machine_type
  zone         = var.machine_zone

  tags = ["external-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
	  size = 450
    }
  }

  // Run the bootstrapper
  metadata_startup_script = file(var.bootstrapper)

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
    preemptible       = false
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

