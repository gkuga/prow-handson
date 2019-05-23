resource "google_compute_network" "network" {
  name                    = "${var.name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "${var.name}"
  ip_cidr_range = "${var.ip_cidr_range}"
  network       = "${google_compute_network.network.name}"
  description   = "prow workshop network"
  region        = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name                     = "${var.name}-cluster"
  location                 = "${var.location}"
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""
  }

	lifecycle {
		ignore_changes = ["master_auth"]
	}
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.name}-node-pool"
  location   = "${var.location}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 2
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-4"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "compute-rw",
      "storage-rw",
      "logging-write",
      "monitoring",
      "trace-append",
      "cloud-platform",
    ]
  }
}
