/***************************************************************************
This creates a network and subnetwork, stands up two VMs, and then
uses ansible to install k8s control plane on one and join the other
as a worker node, on GCP.

Prior to executing terraform apply, run
gcloud services enable compute.googleapis.com
to let terraform work with a project on GCP.
And set $GOOGLE_APPLICATION_CREDENTIALS=the/path/to/application_default_credentials.json

During execution, enter the password for sudo on the ansible host
when the playbooks are running.
*****************************************************************************/
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.6.0"
    }
  }
}

provider "google" {
  # credentials = file(var.credentials_file)
  # Or, put them in $GOOGLE_APPLICATION_CREDENTIALS
  project = var.project
  region  = var.regions[0]
  zone    = var.zone
}

resource "google_project_service" "project" {
  project = var.project
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

module "network" {
    // Explicitly declaring this dependency to avoid network creation error
    depends_on = [
      google_project_service.project,
    ]

    source = "./modules/network"
    regions = var.regions
}

module "compute" {
  // Explicitly declaring this dependency to avoid network creation error
    depends_on = [
      google_project_service.project,
      module.network.terraform-network,
      module.network.terraform_subnetwork,
    ]

    source = "./modules/compute"
    project = var.project
    region = var.regions[0]
    zone = var.zone
    subnetwork = module.network.terraform_subnetwork
    subnetwork_ip_cidr_range = module.network.subnetwork_ip_cidr_range
    ssh_user = var.ssh_user
    ssh_public_key = var.ssh_public_key
}

resource "local_file" "ansible_host" {
    content = templatefile("ansible/templates/hosts.tpl",
        {
            cp_ip = module.compute.cp_ip
            worker_ip = module.compute.worker_ip
            user = var.ssh_user
            ssh_private_key = var.ssh_private_key
        }
    )
    filename = "${path.module}/hosts"
}

resource "null_resource" "ansible_playbook" {
    depends_on = [
        local_file.ansible_host,
        module.compute.terraform-cp,
        module.compute.terraform-worker,
        module.network.terraform-network,
    ]

    provisioner "remote-exec" {
        connection {
            host = module.compute.cp_ip
            user = var.ssh_user
            private_key = "${file(var.ssh_private_key)}"
        }

        inline = ["echo 'cp connected!'"]
    }

    provisioner "remote-exec" {
        connection {
            host = module.compute.worker_ip
            user = var.ssh_user
            private_key = "${file(var.ssh_private_key)}"
        }

        inline = ["echo 'worker connected!'"]
    }

    provisioner "local-exec" {
        command = "ansible-playbook ansible/playbook.yml --ask-become-pass --extra-vars=\"subnetwork_ip_cidr_range=$subnetwork_ip_cidr_range \""
        environment = {
            //cp_ip = module.compute.cp_ip
            //worker_ip = module.compute.worker_ip
            //console_password = module.compute.console_password
            subnetwork_ip_cidr_range = module.network.subnetwork_ip_cidr_range
        }
    }
}
