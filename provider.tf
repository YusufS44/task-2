terraform {
    required_providers {
        google = {
        source = "hashicorp/google"
        version = "5.28.0"
        }
    }
}

provider "google" {
    project = "gcp-class-417400"
    region = "us-east4"
    credentials = var.credentials
}