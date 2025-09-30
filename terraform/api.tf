data "heroku_team" "linc-brain-mit" {
  name = "linc-brain-mit"
}

module "api" {
  source  = "kitware-resonant/resonant/heroku"
  version = "1.1.1"

  project_slug     = "linc-brain-prod"
  heroku_team_name = data.heroku_team.linc-brain-mit.name
  route53_zone_id  = aws_route53_zone.linc-brain-mit.zone_id
  subdomain_name   = "api"

  heroku_web_dyno_size    = "standard-2x"
  heroku_worker_dyno_size = "standard-2x"
  heroku_postgresql_plan  = "standard-0"
  heroku_cloudamqp_plan   = "squirrel-1"
  heroku_papertrail_plan  = "liatorp"

  heroku_web_dyno_quantity    = 1
  heroku_worker_dyno_quantity = 1

    django_default_from_email          = "admin@api.lincbrain.org"
    django_cors_origin_whitelist       = ["https://lincbrain.org"]
    django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+\\.netlify\\.app$"]

    additional_django_vars = {
        CLOUDFRONT_BASE_URL                            = "lincbrain.org"
        CLOUDFRONT_NEUROGLANCER_URL                    = "https://neuroglancer.lincbrain.org"
        CLOUDFRONT_PEM_KEY_ID                          = "K3OG4MF62CGEDN"
        CLOUDFRONT_PRIVATE_PEM_S3_LOCATION             = "cloudfront/private_key_prod_new.pem"
        DJANGO_CONFIGURATION                           = "HerokuProductionConfiguration"
        DJANGO_DANDI_DANDISETS_BUCKET_NAME             = module.sponsored_lincset_bucket_us_east_2.bucket_name
        DJANGO_DANDI_DANDISETS_BUCKET_PREFIX           = ""
        DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_NAME     = module.sponsored_embargo_bucket_us_east_2.bucket_name
        DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_PREFIX   = ""
        DJANGO_DANDI_DANDISETS_LOG_BUCKET_NAME         = module.sponsored_lincset_bucket_us_east_2.log_bucket_name
        DJANGO_DANDI_DANDISETS_EMBARGO_LOG_BUCKET_NAME = module.sponsored_embargo_bucket_us_east_2.log_bucket_name
        DJANGO_SENTRY_DSN                              = "https://833c159dc622528b21b4ce4adef6dbf8@o4506237212033024.ingest.sentry.io/4506237213212672"
        DJANGO_SENTRY_ENVIRONMENT                      = "production"
        DJANGO_CELERY_WORKER_CONCURRENCY               = "4"
        DJANGO_DANDI_WEB_APP_URL                       = "https://lincbrain.org"
        DJANGO_DANDI_API_URL                           = "https://api.lincbrain.org"
        DJANGO_DANDI_JUPYTERHUB_URL                    = "https://hub.dandiarchive.org"
        WEBKNOSSOS_API_URL                             = "https://webknossos.lincbrain.org"
        WEBKNOSSOS_ORGANIZATION_DISPLAY_NAME           = "LINC"
        WEBKNOSSOS_ORGANIZATION_NAME                   = "LINC"
      }
      additional_sensitive_django_vars = {
      }
}

resource "heroku_formation" "api_checksum_worker" {
  app_id   = module.api.heroku_app_id
  type     = "checksum-worker"
  size     = "standard-2x"
  quantity = 1
}

resource "heroku_formation" "api_analytics_worker" {
  app_id   = module.api.heroku_app_id
  type     = "analytics-worker"
  size     = "standard-1x"
  quantity = 1
}

data "aws_iam_user" "api" {
  user_name = module.api.heroku_iam_user_id
}