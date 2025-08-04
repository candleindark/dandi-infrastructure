module "staging_dandiset_bucket" {
  source                  = "./modules/dandiset_bucket"
  bucket_name             = "ember-public-data-sandbox"
  public                  = true
  versioning              = true
  aws_open_data           = true
  allow_heroku_put_object = true
  heroku_user             = data.aws_iam_user.api_staging
  log_bucket_name         = "ember-public-data-sandbox-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}

import {
  to = module.staging_dandiset_bucket.aws_s3_bucket.dandiset_bucket
  id = "ember-open-data-sandbox"
}

import {
  to = module.staging_dandiset_bucket.aws_s3_bucket.log_bucket
  id = "ember-open-data-sandbox-logs"
}

# Note: this bucket is no longer being used
module "staging_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "ember-dandi-api-sandbox-embargo-dandisets"
  versioning      = false
  heroku_user     = data.aws_iam_user.api_staging
  log_bucket_name = "ember-dandi-api-sandbox-embargo-dandisets-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
