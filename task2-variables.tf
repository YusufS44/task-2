variable "project_id" {
  description = "The project ID to deploy into"
  default = "gcp-class-417400"
}

variable "region" {
  description = "The region to deploy into"
  default = "us-east1"
}

variable "zone" {
  description = "The zone to deploy into"
  default = "us-east1-b"  
}

variable "network_name" {
  description = "The name of the network"
  default = "toy-soldiers-87-vpc"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  default = "10.230.1.0/24"
}

variable "subnet_name" {
  description = "The name of the subnet"
  default = "subnet-us-east1-01"
}

variable "instance_name" {
  description = "The name of the instance"
  default = "gocommies87"
}

variable "machine_type" {
  description = "The machine type for the instance"
  default = "n2-standard-2"
}

variable "image" {
  description = "The image to use for the instance"
  default = "debian-cloud/debian-11"
}

variable "instance_count" {
  description = "The number of instances to create"
  default = 1
}