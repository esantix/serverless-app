terraform {
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
#       SPA FRONTEND
######################################################

resource "aws_s3_bucket" "simple-app-bucket" {
  bucket = "esantix-app-bucket"
  policy = templatefile("${path.module}/policies/s3_policy.json",
  {bucket_name = "esantix-app-bucket"})
}

resource "aws_s3_bucket_object" "simple-app-bucket_object" {
  bucket = aws_s3_bucket.simple-app-bucket.id
  key    = "index.html"
  content = templatefile("${path.module}/ui/index.html", {
    lambda_url = "${aws_lambda_function_url.backend_lambda_function_url.function_url}"
  })
}

resource "aws_s3_bucket_website_configuration" "simple-app-bucket" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

}
######################################################
#       LAMBDA BACKEND
######################################################

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/src/app.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "backend_lambda_function" {
  function_name = "esantix-app-backend-lambda"
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "app.lambda_handler"
  timeout          = 10
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_function_url" "backend_lambda_function_url" {
  function_name      = aws_lambda_function.backend_lambda_function.function_name
  authorization_type = "NONE"
}

output "website_url" {
  value =aws_s3_bucket_website_configuration.simple-app-bucket.website_endpoint
}