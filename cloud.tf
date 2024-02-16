terraform {
  cloud {
    organization = "esantix-terraform"

    workspaces {
      name = "esantix-serverless-app-aws"
    }
  }
}