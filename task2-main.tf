terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
    project = var.project_id
    region  = var.region
    zone    = var.zone
}

// Create a new VPC network
resource "google_compute_network" "vpc_network" {
  name = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc_network.self_link
}

// Create a new firewall rule
resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh-http-tcp-icmp"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  allow {
    protocol = "icmp"
  }

allow {
    protocol = "tcp"
    ports    = ["3389"]
}

  source_ranges = ["0.0.0.0/0"]
  description = "Allow HTTP traffic"
  direction = "INGRESS"
  priority = 1000
}

// Create a static IP address
resource "google_compute_address" "static_ip" {
  count = var.instance_count
  name = "static-ip"
  address_type = "EXTERNAL"
  depends_on = [ google_compute_network.vpc_network ]
}

// Create a new instance
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    access_config {
    nat_ip = google_compute_address.static_ip[0].address
    }
  }

  tags = ["allow-ssh-http-tcp-icmp"]

    metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html lang=\"en\">\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>Kar Vastor Video</title>\n    <style>\n        body {\n            background-color: black;\n            color: white;\n            font-family: Arial, sans-serif;\n            display: flex;\n            justify-content: center;\n            align-items: center;\n            height: 100vh;\n            margin: 0;\n        }\n        header {\n            position: absolute;\n            top: 0;\n            width: 100%;\n            text-align: center;\n            font-size: 2em;\n            padding: 20px 0;\n        }\n        iframe {\n            border: none;\n        }\n    </style>\n</head>\n<body>\n    <header>Kar Vastor</header>\n    <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/cIQAWvkSj0g?si=q8mkabsoUt5ATKlS\" title=\"YouTube video player\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen></iframe>\n</body>\n</html>\nEOF"
  }
}