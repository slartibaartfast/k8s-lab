output "terraform_network" {
    value = google_compute_network.terraform_k8s_network.self_link
}

output "terraform_subnetwork" {
    value = google_compute_subnetwork.terraform_k8s_subnetwork[0].self_link
}

output "subnetwork_ip_cidr_range" {
    value = google_compute_subnetwork.terraform_k8s_subnetwork[0].ip_cidr_range
}
