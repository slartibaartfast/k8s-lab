/*******************************************************************************
Create a Network, SubNetwork, and Firewall
*******************************************************************************/
resource "google_compute_network" "terraform_k8s_network" {
  name                    = "terraform-k8s-network"
  auto_create_subnetworks = false
}

// The ip_cidr_range is assuming there are two vms per region
resource "google_compute_subnetwork" "terraform_k8s_subnetwork" {
    count         = length(var.regions)
    name          = "terraform-k8s-subnetwork"
    ip_cidr_range = "10.${count.index+4}.0.0/16"
    network       = google_compute_network.terraform_k8s_network.id
    region        = var.regions[count.index]
}

resource "google_compute_firewall" "terraform_k8s_firewall" {
  name    = "terraform-allow-all"
  network = "terraform-k8s-network"

  allow {
    protocol = "all"
  }

  // Allow traffic from everywhere to instances with a terraform_k8s_firewall tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraform-k8s-firewall"]

  // Terraform wasn't finding the network after it had been created, so declaring this dependency
  depends_on = [
    google_compute_network.terraform_k8s_network,
  ]
}
