variable "region" {}

variable "account" {}

provider "alicloud" {
  region = var.region
  version = "~>1.52"
}

terraform {
  backend "oss" {
    bucket = "ali-serverless-backend-state"
    prefix = "state"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}