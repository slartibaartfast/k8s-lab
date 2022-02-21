variable "project" {
    type = string
}

variable "subnetwork" {
    type = string
}

variable "subnetwork_ip_cidr_range" {
  description = "The ip cidr range of our network"
  type        = string
}

variable "zone" {
    type = string
}

variable "region" {
    type = string
}

variable "ssh_user" {
  description = "user name to connect to the instance"
  type        = string
}

variable "ssh_public_key" {
  description = "public key to be use when creating the instance"
  type        = string
}
