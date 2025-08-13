module "sponsored_dandiset_bucket" {
  source                                = "./modules/dandiset_bucket"
  bucket_name                           = "ember-open-data"
  public                                = true
  versioning                            = true
  aws_open_data                         = true
  allow_cross_account_heroku_put_object = true
  heroku_user                           = data.aws_iam_user.api
  log_bucket_name                       = "ember-open-data-logs"
  providers = {
    aws         = aws.sponsored
    aws.project = aws
  }
}

import {
  
  to = module.sponsored_dandiset_bucket.aws_s3_bucket.dandiset_bucket
  id = "ember-open-data"
}

import {
  to = module.sponsored_dandiset_bucket.aws_s3_bucket.log_bucket
  id = "ember-open-data-logs"
}

// Note: While the embargo bucket is created in AWS, it is NOT actually used.
// Embargoed data is stored in the public bucket defined above
module "sponsored_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "ember-dandi-archive-embargo"
  versioning      = false
  heroku_user     = data.aws_iam_user.api
  log_bucket_name = "ember-dandi-archive-embargo-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
