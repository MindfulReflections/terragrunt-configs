locals {
  aws_region = "eu-central-1"
  vpc_cidr   = "10.20.0.0/16"
  env        = "production"

  # Tags including the Terraform state file path passed in from root inputs
  tags = {
    Environment       = "production"
  }

  # THIS IS AN ARN of the IAM role in the target AWS account (!!PROD!!)
  # that Terraform assumes to deploy and manage cloud resources.
  # This role must have the necessary permissions for Terraform operations.
  terraform_execution_role_arn = "arn:aws:iam::163363909847:role/TerraformExecutionRole"
}
