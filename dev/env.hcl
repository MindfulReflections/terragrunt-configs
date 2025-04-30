locals {
  aws_region = "eu-central-1"
  vpc_cidr   = "10.10.0.0/16"

  # Tags including the Terraform state file path passed in from root inputs
  tags = {
    Environment       = "dev"
    project           = "MindfulReflections"
    ManagedBy         = "Terragrunt"
  }

  # ARN of the IAM role in the target AWS account (e.g., Dev, Staging, Prod)
  # that Terraform assumes to deploy and manage cloud resources.
  # This role must have the necessary permissions for Terraform operations.
  terraform_execution_role_arn = "arn:aws:iam::307926975853:role/TerraformExecutionRole"
}
