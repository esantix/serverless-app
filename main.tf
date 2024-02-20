terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }
}

provider "aws" {
  region = var.region
}

variable "region" {
    default = "us-east-1"
}

variable "app-name" {
    default = "serverless-app"
}
