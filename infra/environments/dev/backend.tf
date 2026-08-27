terraform {
  backend "gcs" {
    bucket = "tfstate-lbobak-gcp-platform-lab-dev"
    prefix = "dev"
  }
}