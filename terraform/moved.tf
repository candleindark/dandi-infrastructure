# TODO: these are the old staging resourcVes that we are moving to sandbox.
# They will be removed once the sandbox is fully operational and the staging
# resources are no longer needed.
moved {
  from = module.api.module.heroku
  to   = module.api_heroku
}

moved {
  from = module.api.module.smtp
  to   = module.api_smtp
}

moved {
  from = module.api.random_string.django_secret
  to   = random_string.api_django_secret
}

moved {
  from = module.api.aws_route53_record.heroku
  to   = aws_route53_record.api_heroku
}

moved {
  from = module.api.aws_iam_user.heroku_user
  to   = aws_iam_user.api_heroku_user
}

moved {
  from = module.api.aws_iam_access_key.heroku_user
  to   = aws_iam_access_key.api_heroku_user
}
