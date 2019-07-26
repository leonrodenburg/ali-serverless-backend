variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-central-1"
}

provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
  version = "~>1.52"
}

terraform {
  backend "oss" {
    bucket = "ali-serverless-backend-state"
    prefix = "state"
    key    = "terraform.tfstate"
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
  }
}