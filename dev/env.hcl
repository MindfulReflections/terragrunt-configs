locals {
  aws_region = "eu-central-1"
  vpc_cidr   = "10.10.0.0/16"

  # Tags including the Terraform state file path passed in from root inputs
  tags = {
    Environment       = "dev"
  }

  private = read_terragrunt_config(find_in_parent_folders("private.hcl")).locals

  # THIS IS AN ARN of the IAM role in the target AWS account (!!PROD!!)
  # that Terraform assumes to deploy and manage cloud resources.
  # This role must have the necessary permissions for Terraform operations.
  # terraform_execution_role_arn = "arn:aws:iam::163363909847:role/TerraformExecutionRole"
  terraform_execution_role_arn = local.private.terraform_execution_role_arn
}
