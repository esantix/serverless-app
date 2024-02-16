######################################################
#       SPA FRONTEND
######################################################

locals {
  bucket_name = "${var.app-name}-fend-bucket"
}

resource "aws_s3_bucket" "fend-app-bucket" {
  bucket = local.bucket_name
  policy = templatefile("${path.module}/policies/s3_policy.json",
    {
      bucket_name = local.bucket_name
  })
}

resource "aws_s3_object" "fend-app-bucket_object" {
  bucket       = aws_s3_bucket.fend-app-bucket.id
  key          = "index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/ui/index.html", {
    lambda_url = "${aws_lambda_function_url.backend_lambda_function_url.function_url}"
  })
}

resource "aws_s3_bucket_website_configuration" "fend-app-bucket-website-url" {
  bucket = aws_s3_bucket.fend-app-bucket.id

  index_document {
    suffix = "index.html"
  }

}

######################################################
#       OUTPUTS
######################################################

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.fend-app-bucket-website-url}/index.html"
}
