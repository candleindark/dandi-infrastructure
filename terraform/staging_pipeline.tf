# See api.tf for the definition of the production app


module "api_staging" {
  source  = "kitware-resonant/resonant/heroku"
  version = "1.1.1"

  project_slug     = "linc-brain-staging"
  heroku_team_name = data.heroku_team.linc-brain-mit.name
  route53_zone_id  = aws_route53_zone.linc-brain-mit.zone_id
  subdomain_name   = "staging-api"

  heroku_web_dyno_size    = "basic"
  heroku_worker_dyno_size = "basic"
  heroku_postgresql_plan  = "basic"
  heroku_cloudamqp_plan   = "tiger"
  heroku_papertrail_plan  = "fixa"

  heroku_web_dyno_quantity    = 1
  heroku_worker_dyno_quantity = 1

  django_default_from_email          = "admin@staging-api.lincbrain.org"
  django_cors_origin_whitelist       = ["https://gui-staging.lincbrain.org", "https://staging--lincbrain-org.netlify.app"]
  django_cors_origin_regex_whitelist = ["https://staging--gui-staging-lincbrain-org.netlify.app"]

  additional_django_vars = {
    CLOUDFRONT_BASE_URL                            = "lincbrain.org"
    CLOUDFRONT_NEUROGLANCER_URL                    = "https://neuroglancer-staging.lincbrain.org"
    CLOUDFRONT_PEM_KEY_ID                          = "KZQ92MU8PCLJ8"
    CLOUDFRONT_PRIVATE_PEM_S3_LOCATION             = "cloudfront/private_key_staging_new.pem"
    DJANGO_CONFIGURATION                           = "HerokuStagingConfiguration"
    DJANGO_DANDI_DANDISETS_BUCKET_NAME             = module.staging_lincset_bucket_us_east_2.bucket_name
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX           = ""
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_NAME     = module.staging_embargo_bucket_us_east_2.bucket_name
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_PREFIX   = ""
    DJANGO_DANDI_DANDISETS_LOG_BUCKET_NAME         = module.staging_lincset_bucket_us_east_2.log_bucket_name
    DJANGO_DANDI_DANDISETS_EMBARGO_LOG_BUCKET_NAME = module.staging_embargo_bucket_us_east_2.log_bucket_name
    DJANGO_SENTRY_DSN                              = "https://833c159dc622528b21b4ce4adef6dbf8@o4506237212033024.ingest.sentry.io/4506237213212672"
    DJANGO_SENTRY_ENVIRONMENT                      = "staging"
    DJANGO_CELERY_WORKER_CONCURRENCY               = "2"
    DJANGO_DANDI_INSTANCE_NAME                     = "DANDI-STAGING"
    DJANGO_DANDI_WEB_APP_URL                       = "https://staging--lincbrain-org.netlify.app"
    DJANGO_DANDI_API_URL                           = "https://staging-api.lincbrain.org"
    DJANGO_DANDI_JUPYTERHUB_URL                    = "https://hub.dandiarchive.org/"
    WEBKNOSSOS_API_URL                             = "https://webknossos-staging.lincbrain.org"
    WEBKNOSSOS_ORGANIZATION_DISPLAY_NAME           = "LINC Staging"
    WEBKNOSSOS_ORGANIZATION_NAME                   = "LINC_Staging"
  }
  additional_sensitive_django_vars = {
  }
}

resource "heroku_formation" "api_staging_checksum_worker" {
  app_id   = module.api_staging.heroku_app_id
  type     = "checksum-worker"
  size     = "basic"
  quantity = 1
}

resource "heroku_formation" "api_staging_analytics_worker" {
  app_id   = module.api_staging.heroku_app_id
  type     = "analytics-worker"
  size     = "basic"
  quantity = 1
}

data "aws_iam_user" "api_staging" {
  user_name = module.api_staging.heroku_iam_user_id
}

resource "heroku_pipeline" "linc_pipeline" {
  name = "linc-pipeline"

  owner {
    id   = data.heroku_team.linc-brain-mit.id
    type = "team"
  }
}

resource "heroku_pipeline_coupling" "staging" {
  app_id   = module.api_staging.heroku_app_id
  pipeline = heroku_pipeline.linc_pipeline.id
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app_id   = module.api.heroku_app_id
  pipeline = heroku_pipeline.linc_pipeline.id
  stage    = "production"
}