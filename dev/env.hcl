locals {
  aws_region = "eu-central-1"
  vpc_cidr   = "10.10.0.0/16"

  # Tags including the Terraform state file path passed in from root inputs
  tags = {
    Environment = "dev"
  }

  private = read_terragrunt_config("${dirname(find_in_parent_folders("root.hcl"))}/common_vars/private.hcl").locals

  # THIS IS AN ARN of the IAM role in the target AWS account (DEV)
  # that Terraform assumes to deploy and manage cloud resources.
  # This role must have the necessary permissions for Terraform operations.

  terraform_execution_role_arn = local.private.dev_terraform_execution_role_arn
}
