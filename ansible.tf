resource "local_file" "inventory" {
  content  = join("\n", formatlist("%s ansible_host=%s ansible_user=%s ansible_ssh_private_key_file=\"%s\"", local.all_instances, local.instance_ips, var.username, local.keyfile_pvt))
  filename = var.inventory_file
}

resource "null_resource" "ansible" {
  triggers = {
    for_ips = join(",", local.instance_ips)
  }

  provisioner "local-exec" {
    command = "ansible-playbook --connection=ssh --ssh-common-args='-o StrictHostKeyChecking=no' -i ${var.inventory_file} ${var.playbook_file} -e 'ansible_python_interpreter=/usr/bin/python3'"
  }

  depends_on = [local_file.inventory]
}

