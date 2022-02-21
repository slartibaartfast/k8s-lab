variable "project" {
  description = "The GCP project"
  type        = string
}

variable "service_account_email" {
  description = "The email used for the service account"
  type        = string
}

variable "regions" {
  description = "The GCP regions used"
  default     = ["us-central1"]
  type        = list
}

variable "zone" {
  description = "The GCP zone used"
  default     = "us-central1-a"
  type        = string
}

//variable "subnetwork_ip_cidr_range" {
//  description = "The ip cidr range of our network"
//  type        = string
//}

variable "ssh_private_key" {
  description = "Private key for connecting"
  type        = string
}

variable "ssh_public_key" {
  description = "Public key for connecting"
  type        = string
}

variable "ssh_user" {
  description = "Username for connecting"
  type        = string
}
