/******************************************************************************
Create a VM for a control plane, and another for a worker node

TODO: Move some hard coded strings to variables, such as instance names
*******************************************************************************/

resource "random_password" "password" {
    length           = 16
    special          = true
    upper            = true
    lower            = true
    number           = true
    override_special = "_%@!"
}

resource "google_compute_instance" "terraform-cp" {
  name         = "terraform-cp"
  machine_type = "n1-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      size  = "20"
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network            = "terraform-k8s-network"
    subnetwork         = var.subnetwork
    subnetwork_project = var.project
    access_config {
      // Ephemeral IP
    }
    //alias_ip_range {
      //ip_cidr_range = "10.1.0.0/16"
      //ip_cidr_range = var.subnetwork_ip_cidr_range
    //}
  }

  metadata = {
  // oslogin is a setting needed when using one of the ways to use ansible
  //  enable-oslogin = "true"
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  //metadata_startup_script = "sudo apt-get update"
  //metadata_startup_script = file(var.cp_startup_script)

  //service_account {
  //  # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  //  email  = var.service_account_email
  //  scopes = ["cloud-platform"]
  //}

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["terraform-k8s-firewall"]
}

resource "google_compute_instance" "terraform-worker" {
  name         = "terraform-worker"
  machine_type = "n1-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      size  = "20"
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network            = "terraform-k8s-network"
    subnetwork         =  var.subnetwork
    subnetwork_project = var.project
    access_config {
      // Ephemeral IP
    }
    //alias_ip_range {
      //ip_cidr_range = var.subnetwork_ip_cidr_range
    //}
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["terraform-k8s-firewall"]
}
