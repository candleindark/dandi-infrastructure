moved {
  from = module.api_staging.module.heroku.heroku_app.heroku
  to   = module.api_sandbox.module.heroku.heroku_app.heroku
}

moved {
  from = module.api_staging.module.heroku.heroku_formation.heroku_worker
  to   = module.api_sandbox.module.heroku.heroku_formation.heroku_worker
}

moved {
  from = module.api_staging.random_string.django_secret
  to   = module.api_sandbox.random_string.django_secret
}

moved {
  from = module.api_staging.module.heroku.heroku_formation.heroku_web
  to   = module.api_sandbox.module.heroku.heroku_formation.heroku_web
}

moved {
  from = module.api_staging.module.heroku.heroku_addon.heroku_postgresql[0]
  to   = module.api_sandbox.module.heroku.heroku_addon.heroku_postgresql[0]
}

moved {
  from = module.api_staging.module.heroku.heroku_addon.heroku_papertrail[0]
  to   = module.api_sandbox.module.heroku.heroku_addon.heroku_papertrail[0]
}

moved {
  from = module.api_staging.aws_iam_access_key.heroku_user
  to   = module.api_sandbox.aws_iam_access_key.heroku_user
}

moved {
  from = module.api_staging.module.heroku.heroku_addon.heroku_cloudamqp[0]
  to   = module.api_sandbox.module.heroku.heroku_addon.heroku_cloudamqp[0]
}

moved {
  from = module.api_staging.aws_iam_user.heroku_user
  to   = module.api_sandbox.aws_iam_user.heroku_user
}

moved {
  from = module.api_staging.module.smtp.aws_route53_record.smtp_dkim[1]
  to   = module.api_sandbox.module.smtp.aws_route53_record.smtp_dkim[1]
}

moved {
  from = module.api_staging.aws_iam_user_policy.heroku_user_storage
  to   = module.api_sandbox.aws_iam_user_policy.heroku_user_storage
}

moved {
  from = module.api_staging.module.smtp.aws_route53_record.smtp_dkim[2]
  to   = module.api_sandbox.module.smtp.aws_route53_record.smtp_dkim[2]
}

moved {
  from = module.api_staging.module.smtp.aws_ses_domain_identity_verification.smtp_verification
  to   = module.api_sandbox.module.smtp.aws_ses_domain_identity_verification.smtp_verification
}

moved {
  from = module.api_staging.module.smtp.aws_iam_user_policy.smtp
  to   = module.api_sandbox.module.smtp.aws_iam_user_policy.smtp
}

moved {
  from = module.api_staging.module.smtp.aws_iam_access_key.smtp
  to   = module.api_sandbox.module.smtp.aws_iam_access_key.smtp
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_public_access_block.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_public_access_block.storage
}

moved {
  from = module.api_staging.module.smtp.aws_iam_user.smtp
  to   = module.api_sandbox.module.smtp.aws_iam_user.smtp
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_server_side_encryption_configuration.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_server_side_encryption_configuration.storage
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_policy.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_policy.storage
}

moved {
  from = module.api_staging.module.heroku.heroku_app.heroku
  to   = module.api_sandbox.module.heroku.heroku_app.heroku
}

moved {
  from = module.api_staging.module.smtp.aws_route53_record.smtp_dkim[0]
  to   = module.api_sandbox.module.smtp.aws_route53_record.smtp_dkim[0]
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_ownership_controls.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_ownership_controls.storage
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_cors_configuration.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_cors_configuration.storage
}

moved {
  from = module.api_staging.module.smtp.aws_ses_domain_dkim.smtp
  to   = module.api_sandbox.module.smtp.aws_ses_domain_dkim.smtp
}

moved {
  from = module.api_staging.module.smtp.aws_ses_domain_identity.smtp
  to   = module.api_sandbox.module.smtp.aws_ses_domain_identity.smtp
}

moved {
  from = module.api_staging.module.smtp.aws_route53_record.smtp_verification
  to   = module.api_sandbox.module.smtp.aws_route53_record.smtp_verification
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket.storage
}

moved {
  from = module.api_staging.module.storage.aws_s3_bucket_lifecycle_configuration.storage
  to   = module.api_sandbox.module.storage.aws_s3_bucket_lifecycle_configuration.storage
}
