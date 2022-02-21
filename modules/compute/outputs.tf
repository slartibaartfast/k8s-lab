output "cp_ip" {
  value = google_compute_instance.terraform-cp.network_interface.0.access_config.0.nat_ip
}

output "worker_ip"{
  value = google_compute_instance.terraform-worker.network_interface.0.access_config.0.nat_ip
}

output "terraform_cp" {
    value = google_compute_instance.terraform-cp.self_link
}

output "terraform_worker" {
    value = google_compute_instance.terraform-worker.self_link
}

output "console_password" {
    sensitive = true
    value = random_password.password.result
}
