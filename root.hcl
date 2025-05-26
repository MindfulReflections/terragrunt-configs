locals {
  environment_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  terraform_state_path = "${path_relative_to_include()}/terraform.tfstate"
  private              = read_terragrunt_config("${dirname(find_in_parent_folders("root.hcl"))}/common_vars/private.hcl").locals

}

inputs = {
  terraform_state_path = local.terraform_state_path
}


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket                      = "mindfulreflections-terraform-state"
    dynamodb_table              = "mindfulreflections-terraform-locks"
    region                      = local.environment_vars.aws_region
    encrypt                     = true
    key                         = local.terraform_state_path
    skip_region_validation      = true
    skip_credentials_validation = true

    # Assume back to the root AWS account to store the Terraform state
    # Because the Terraform state bucket is in the root account
    assume_role = try(

      { role_arn = local.private.terraform_state_access_role_arn },
      null
    )
  }
}

# Here we are generating the provider configuration for the AWS provider
# This is necessary because we are assuming a role to deploy resources
# in the target AWS account
generate "provider" {
  path      = "provider-tg.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.environment_vars.aws_region}"

  assume_role {
    role_arn     = "${local.environment_vars.terraform_execution_role_arn}"
  }
}
EOF
}