terraform {
  backend "s3" {
    bucket = "rasp6045-terraform-backend"
    key    = "dev/highly_available_infra"
    region = "us-east-1"
  }
}