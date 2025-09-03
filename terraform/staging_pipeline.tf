module "api_sandbox_smtp" {
  source  = "kitware-resonant/resonant/heroku//modules/smtp"
  version = "2.1.1"

  fqdn            = "api-dandi-sandbox.emberarchive.org"
  project_slug    = "ember-dandi-api-sandbox"
  route53_zone_id = aws_route53_zone.dandi_sandbox.zone_id
}

resource "random_string" "api_sandbox_django_secret" {
  length  = 64
  special = false
}

module "api_sandbox_heroku" {
  source  = "kitware-resonant/resonant/heroku//modules/heroku"
  version = "2.1.1"

  team_name = data.heroku_team.dandi.name
  app_name  = "ember-dandi-api-sandbox"
  fqdn      = "api-dandi-sandbox.emberarchive.org"

  config_vars = {
    AWS_ACCESS_KEY_ID                  = aws_iam_access_key.api_sandbox_heroku_user.id
    AWS_DEFAULT_REGION                 = data.aws_region.current.name
    DJANGO_ALLOWED_HOSTS               = join(",", ["https://apl-setup--ember-dandi-archive.netlify.app", "https://api-dandi-sandbox.emberarchive.org"])
    DJANGO_CORS_ALLOWED_ORIGINS        = join(",", ["https://apl-setup--ember-dandi-archive.netlify.app", "https://neurosift.app"])
    DJANGO_CORS_ALLOWED_ORIGIN_REGEXES = join(",", ["^https:\\/\\/[0-9a-z\\-]+--dandi-sandbox.emberarchive-org\\.netlify\\.app$", "^https:\\/\\/[0-9a-z\\-]+--ember-dandi-archive\\.netlify\\.app$"])
    DJANGO_DEFAULT_FROM_EMAIL          = "admin@api-dandi-sandbox.emberarchive.org"
    DJANGO_SETTINGS_MODULE             = "dandiapi.settings.heroku_production"
    DJANGO_STORAGE_BUCKET_NAME         = module.staging_dandiset_bucket.bucket_name

    # DANDI-specific variables
    DJANGO_CELERY_WORKER_CONCURRENCY = "2"
    DJANGO_SENTRY_DSN                = data.sentry_key.this.dsn_public
    DJANGO_SENTRY_ENVIRONMENT        = "staging"
    DJANGO_DANDI_WEB_APP_URL         = "https://apl-setup--ember-dandi-archive.netlify.app" // Future: "dandi-sandbox.emberarchive.org"
    DJANGO_DANDI_API_URL             = "https://api-dandi-sandbox.emberarchive.org"
    DJANGO_DANDI_JUPYTERHUB_URL      = "https://hub.dandiarchive.org/"
    DJANGO_DANDI_DOI_API_URL         = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER        = "JHU.NXHEVY"
    DJANGO_DANDI_DOI_API_PREFIX      = "10.82754"
    DJANGO_DANDI_DOI_PUBLISH         = "false"

    # These may be removed in the future
    DJANGO_DANDI_DANDISETS_BUCKET_NAME   = module.staging_dandiset_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX = ""
    DJANGO_DANDI_DEV_EMAIL               = var.dev_email
    DJANGO_DANDI_ADMIN_EMAIL             = "info@emberarchive.org"
  }
  sensitive_config_vars = {
    AWS_SECRET_ACCESS_KEY         = aws_iam_access_key.api_sandbox_heroku_user.secret
    DJANGO_EMAIL_URL              = "smtp+tls://${urlencode(module.api_sandbox_smtp.username)}:${urlencode(module.api_sandbox_smtp.password)}@${module.api_sandbox_smtp.host}:${module.api_sandbox_smtp.port}"
    DJANGO_SECRET_KEY             = random_string.api_sandbox_django_secret.result
    DJANGO_DANDI_DOI_API_PASSWORD = var.test_doi_api_password
  }

  web_dyno_size        = "basic"
  web_dyno_quantity    = 1
  worker_dyno_size     = "basic"
  worker_dyno_quantity = 1
  postgresql_plan      = "essential-0" // "essential-1"
  cloudamqp_plan       = "ermine" // "tiger"
  papertrail_plan      = "choklad" // "fixa"
}

resource "heroku_formation" "api_sandbox_checksum_worker" {
  app_id   = module.api_sandbox_heroku.app_id
  type     = "checksum-worker"
  size     = "basic"
  quantity = 1
}

resource "aws_route53_record" "api_sandbox_heroku" {
  zone_id = aws_route53_zone.dandi_sandbox.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = [module.api_sandbox_heroku.cname]
}

resource "aws_iam_user" "api_sandbox_heroku_user" {
  name = "ember-dandi-api-sandbox-heroku"
}

resource "aws_iam_access_key" "api_sandbox_heroku_user" {
  user = aws_iam_user.api_sandbox_heroku_user.name
}

resource "heroku_pipeline" "dandi_pipeline" {
  name = "ember-dandi-pipeline"

  owner {
    id   = data.heroku_team.dandi.id
    type = "team"
  }
}

resource "heroku_pipeline_coupling" "staging" {
  app_id   = module.api_sandbox_heroku.app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app_id   = module.api_heroku.app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "production"
}
