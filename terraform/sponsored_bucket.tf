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

module "sponsored_embargo_bucket" {
  source          = "./modules/dandiset_bucket"
  bucket_name     = "ember-dandi-archive-private"
  versioning      = false
  heroku_user     = data.aws_iam_user.api
  log_bucket_name = "ember-dandi-archive-private-logs"
  providers = {
    aws         = aws
    aws.project = aws
  }
}
