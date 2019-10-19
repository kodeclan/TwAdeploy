// Terraform Provider Used to generate random IDs
provider "random" {
  version = "~> 2.1"
}

// Terraform Provider Configuration for Google
provider "google" {
  version     = "~> 2.3"
  credentials = file(var.credentials)
  project     = var.project
  region      = "us-east4-c"
}

// Terraform Provider Used to execute arbitraty commands
provider "null" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

