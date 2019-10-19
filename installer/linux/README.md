# Linux installer

These shell scripts will install [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) for the __current user__.

These scripts need to be executed with root privileges.

__`terraform.sh`__ will fetch the latest available version from HashiCorp, download it and install it to `/usr/local/bin`. It will also install _`curl`_ and _`jq`_ which are needed by the script to work.

__`ansible.sh`__ will install the latest version of ansible from the [Python Package Index](https://pypi.org/project/ansible/). This script also installs Python 3 (Python 2 is slated to be deprecated soon).

While there are a few resources out there that suggest using the inbuilt package manager, we bypass that to make sure we always have the latest stable build. The linux package repositories are quite often running behind in this regard.
