terraform {
  backend "remote" {
    organization = "BBQS-EMBER"

    workspaces {
      name = "ember-dandi-infrastructure"
    }
  }
}

// This is the "project" account, the primary account with most resources
// REDD-EMBER AWS Account
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["503561422188"]
  # Must set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY envvars in Terraform
}

// The "sponsored" account, the Amazon-sponsored account with the public bucket
// Open Data AWS Account
provider "aws" {
  alias               = "sponsored"
  region              = "us-east-1"
  allowed_account_ids = ["650477180493"]

  // This will authenticate using credentials from the project account, then assume the
  // "dandi-infrastructure" role from the sponsored account to manage resources there
  assume_role {
    role_arn = "arn:aws:iam::650477180493:role/dandi-infrastructure"
  }

  # Must set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY envvars for project account in Terraform
}

provider "heroku" {
  # Must set HEROKU_EMAIL, HEROKU_API_KEY envvars in Terraform
}

provider "sentry" {
  # Must set SENTRY_AUTH_TOKEN envvar in Terraform
}

provider "improvmx" {
  # Must set IMPROVMX_API_TOKEN envvar
}

data "aws_canonical_user_id" "project_account" {}

data "aws_caller_identity" "project_account" {}

data "aws_canonical_user_id" "sponsored_account" {
  provider = aws.sponsored
}

data "aws_caller_identity" "sponsored_account" {
  provider = aws.sponsored
}

data "aws_region" "current" {}

data "heroku_team" "dandi" {
  name = "ember-dandi"
}
