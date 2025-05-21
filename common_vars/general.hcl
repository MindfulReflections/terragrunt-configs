locals {
  env = {
    aws_region = "eu-central-1"

    ssh_keys = [
      "ssh-rsa AAAAB3N..."
    ]

    tags = {
      Project   = "MindfulReflections"
      Owner     = "DevOps"
      ManagedBy = "Terragrunt"
    }
  }
}
