######################################################
#       LAMBDA BACKEND
######################################################

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/app/backend/lambda/app.py"
  output_path = "lambda.zip"
}

resource "null_resource" "pip_install" {
  triggers = {
    shell_hash = "${sha256(file("${path.module}/app/backend/lambda/requirements.txt"))}"
  }

  provisioner "local-exec" {
    command = "python3 -m pip install -r ${path.module}/app/backend/lambda/requirements.txt -t ${path.module}/layer"
  }
}

resource "aws_lambda_function" "backend_lambda_function" {
  function_name    = "${var.app-name}-backend-lambda"
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
