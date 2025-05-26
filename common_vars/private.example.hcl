/*
  This file serves as a template for storing sensitive IAM role ARNs
  required for Terragrunt-based deployments.

  It should be copied to `private.hcl` and populated with real account-specific
  values before any `terragrunt apply` is executed.

  This file must never be committed to version control.
  The actual `private.hcl` file is referenced in each environment's `env.hcl`
  and provides critical inputs for:
    - assuming deployment roles in dev and prod accounts
    - writing Terraform state to the root account backend
*/


locals {

  # ARN of the IAM role to assume in the production account for deployments.
  # This role must have permissions to create/manage AWS resources in prod.
  prod_terraform_execution_role_arn = "arn:aws:iam::<PROD_ACCOUNT_ID>:role/TerraformExecutionRole"

  # ARN of the IAM role to assume in the development account for deployments.
  # This role must have permissions to create/manage AWS resources in dev.
  dev_terraform_execution_role_arn  = "arn:aws:iam::<DEV_ACCOUNT_ID>:role/TerraformExecutionRole"

  # ARN of the IAM role in the root account that grants access to the Terraform backend.
  # This is used for reading/writing S3 state and DynamoDB locks from the child accounts.
  terraform_state_access_role_arn = "arn:aws:iam::<ROOT_ACCOUNT_ID>:role/TerraformStateAccess"
}
