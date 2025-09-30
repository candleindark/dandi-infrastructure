module "api_smtp" {
  source  = "kitware-resonant/resonant/heroku//modules/smtp"
  version = "2.1.1"

  fqdn            = "api.dandiarchive.org"
  project_slug    = "dandi-api"
  route53_zone_id = aws_route53_zone.dandi.zone_id
}

resource "random_string" "api_django_secret" {
  length  = 64
  special = false
}

module "api_heroku" {
  source  = "kitware-resonant/resonant/heroku//modules/heroku"
  version = "2.1.1"

  team_name = data.heroku_team.dandi.name
  app_name  = "dandi-api"
  fqdn      = "api.dandiarchive.org"

  config_vars = {
    AWS_ACCESS_KEY_ID                  = aws_iam_access_key.api_heroku_user.id
    AWS_DEFAULT_REGION                 = data.aws_region.current.name
    DJANGO_ALLOWED_HOSTS               = "api.dandiarchive.org"
    DJANGO_CORS_ALLOWED_ORIGINS        = join(",", ["https://dandiarchive.org", "https://neurosift.app"])
    DJANGO_CORS_ALLOWED_ORIGIN_REGEXES = join(",", ["^https:\\/\\/[0-9a-z\\-]+--gui-dandiarchive-org\\.netlify\\.app$"])
    DJANGO_DEFAULT_FROM_EMAIL          = "admin@api.dandiarchive.org"
    DJANGO_SETTINGS_MODULE             = "dandiapi.settings.heroku_production"
    DJANGO_STORAGE_BUCKET_NAME         = module.sponsored_dandiset_bucket.bucket_name

    # DANDI-specific variables
    DJANGO_CELERY_WORKER_CONCURRENCY = "4"
    DJANGO_SENTRY_DSN                = data.sentry_key.this.dsn_public
    DJANGO_SENTRY_ENVIRONMENT        = "production"
    DJANGO_DANDI_WEB_APP_URL         = "https://dandiarchive.org"
    DJANGO_DANDI_API_URL             = "https://api.dandiarchive.org"
    DJANGO_DANDI_JUPYTERHUB_URL      = "https://hub.dandiarchive.org/"
    DJANGO_DANDI_DOI_API_URL         = "https://api.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER        = "dartlib.dandi"
    DJANGO_DANDI_DOI_API_PREFIX      = "10.48324"
    DJANGO_DANDI_DOI_PUBLISH         = "true"
    DJANGO_DANDI_INSTANCE_NAME       = "DANDI"
    DJANGO_DANDI_INSTANCE_IDENTIFIER = "RRID:SCR_017571"

    # These may be removed in the future
    DJANGO_DANDI_DANDISETS_BUCKET_NAME   = module.sponsored_dandiset_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX = ""
    DJANGO_DANDI_DEV_EMAIL               = var.dev_email
    DJANGO_DANDI_ADMIN_EMAIL             = "info@dandiarchive.org"
  }
  sensitive_config_vars = {
    AWS_SECRET_ACCESS_KEY         = aws_iam_access_key.api_heroku_user.secret
    DJANGO_EMAIL_URL              = "smtp+tls://${urlencode(module.api_smtp.username)}:${urlencode(module.api_smtp.password)}@${module.api_smtp.host}:${module.api_smtp.port}"
    DJANGO_SECRET_KEY             = random_string.api_django_secret.result
    DJANGO_DANDI_DOI_API_PASSWORD = var.doi_api_password
  }

  web_dyno_size        = "standard-2x"
  web_dyno_quantity    = 3
  worker_dyno_size     = "standard-2x"
  worker_dyno_quantity = 1
  postgresql_plan      = "standard-0"
  cloudamqp_plan       = "squirrel-1"
  papertrail_plan      = "fredrik"
}

resource "heroku_formation" "api_checksum_worker" {
  app_id   = module.api_heroku.app_id
  type     = "checksum-worker"
  size     = "standard-2x"
  quantity = 1
}

resource "aws_route53_record" "api_heroku" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = [module.api_heroku.cname]
}

resource "aws_iam_user" "api_heroku_user" {
  name = "dandi-api-heroku"
}

resource "aws_iam_access_key" "api_heroku_user" {
  user = aws_iam_user.api_heroku_user.name
}

# A user that can assist with programmatic backup from the bucket.
resource "aws_iam_user" "backup" {
  name = "backup"
}
