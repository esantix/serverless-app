terraform {
  cloud {
    organization = "esantix-terraform"

    workspaces {
      name = "esantix-aws"
    }
  }

 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}


######################################################
#       Frontend
######################################################





resource "aws_s3_bucket" "simple-app-bucket" {
  bucket = "esantix-simple-app-bucket"
}



resource "aws_s3_bucket_object" "simple-app-bucket_object" {
  bucket = aws_s3_bucket.simple-app-bucket.id
  key    = "html"
  source =  templatefile("ui/index.html", {
    lambda_url = "some url"
  })
}

######################################################
#       Backend
######################################################

#module "lambda_function" {
 # source = "terraform-aws-modules/lambda/aws"

  #function_name = "esantix-simple-app-lambda"
  #description   = "Backeend for serverless app"
  #runtime       = "python3.8"

#  source_path = "./lambda/src/app.py"

 # create_lambda_function_url = true

#}


