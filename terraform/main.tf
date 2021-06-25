terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    #   version = "3.73.0"
    }
  }
}

provider "google" {
  credentials = file("")
  project     = ""
}

data "" "" {
  family  = ""
  project = ""
}

resource "google_compute_network" "vpc_network" {
  name        = ""
}