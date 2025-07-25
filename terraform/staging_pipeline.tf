# See api.tf for the definition of the production app


module "api_sandbox" {
  source  = "kitware-resonant/resonant/heroku"
  version = "1.1.1"

  project_slug     = "ember-dandi-api-sandbox"
  heroku_team_name = data.heroku_team.dandi.name
  route53_zone_id  = aws_route53_zone.dandi.zone_id
  subdomain_name   = "api-dandi-sandbox"

  heroku_web_dyno_size    = "basic"
  heroku_worker_dyno_size = "basic"
  heroku_postgresql_plan  = "essential-0" // "essential-1"
  heroku_cloudamqp_plan   = "ermine" // "tiger"
  heroku_papertrail_plan  = "choklad" // "fixa"

  heroku_web_dyno_quantity    = 1
  heroku_worker_dyno_quantity = 1

  django_default_from_email          = "admin@api-dandi-sandbox.emberarchive.org"
  django_cors_origin_whitelist       = ["https://apl-setup--ember-dandi-archive.org", "https://neurosift.app"]
  django_cors_origin_regex_whitelist = ["^https:\\/\\/[0-9a-z\\-]+--gui-dandi-sandbox.emberarchive-org\\.netlify\\.app$",
                                        "^https:\\/\\/[0-9a-z\\-]+--ember-dandi-archive\\.netlify\\.app$"]

  additional_django_vars = {
    DJANGO_CONFIGURATION                           = "HerokuStagingConfiguration"
    DJANGO_DANDI_DANDISETS_BUCKET_NAME             = module.staging_dandiset_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_BUCKET_PREFIX           = ""
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_NAME     = module.staging_embargo_bucket.bucket_name
    DJANGO_DANDI_DANDISETS_EMBARGO_BUCKET_PREFIX   = ""
    DJANGO_DANDI_DANDISETS_LOG_BUCKET_NAME         = module.staging_dandiset_bucket.log_bucket_name
    DJANGO_DANDI_DANDISETS_EMBARGO_LOG_BUCKET_NAME = module.staging_embargo_bucket.log_bucket_name
    DJANGO_DANDI_DOI_API_URL                       = "https://api.test.datacite.org/dois"
    DJANGO_DANDI_DOI_API_USER                      = "JHU.NXHEVY"
    DJANGO_DANDI_DOI_API_PREFIX                    = "10.82754"
    DJANGO_DANDI_DOI_PUBLISH                       = "false"
    DJANGO_SENTRY_DSN                              = data.sentry_key.this.dsn_public
    DJANGO_SENTRY_ENVIRONMENT                      = "staging"
    DJANGO_CELERY_WORKER_CONCURRENCY               = "2"
    DJANGO_DANDI_WEB_APP_URL                       = "https://apl-setup--ember-dandi-archive.netlify.app/"   # was "https://gui-dandi-sandbox.emberarchive.org"
    DJANGO_DANDI_API_URL                           = "https://api-dandi-sandbox.emberarchive.org"
    DJANGO_DANDI_JUPYTERHUB_URL                    = "https://hub-dandi.emberarchive.org/"
    DJANGO_DANDI_DEV_EMAIL                         = var.dev_email
    DJANGO_DANDI_ADMIN_EMAIL                       = "info@emberarchive.org"

    # TODO: this variable is normally defined internally by the `kitware-resonant/resonant/heroku`
    # module, but we need to temporarily override it here to allow both the staging and sandbox
    # URLs to be used concurrently. Once we're ready to make the full switchover to sandbox,
    # this can be removed.
    # DJANGO_ALLOWED_HOSTS = "api-staging.dandiarchive.org,api.sandbox.dandiarchive.org"
  }
  additional_sensitive_django_vars = {
    DJANGO_DANDI_DOI_API_PASSWORD = var.test_doi_api_password
  }
}

resource "heroku_formation" "api_staging_checksum_worker" {
  app_id   = module.api_sandbox.heroku_app_id
  type     = "checksum-worker"
  size     = "basic"
  quantity = 1
}

data "aws_iam_user" "api_staging" {
  user_name = module.api_sandbox.heroku_iam_user_id
}

resource "heroku_pipeline" "dandi_pipeline" {
  name = "ember-dandi-pipeline"

  owner {
    id   = data.heroku_team.dandi.id
    type = "team"
  }
}

resource "heroku_pipeline_coupling" "staging" {
  app_id   = module.api_sandbox.heroku_app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app_id   = module.api.heroku_app_id
  pipeline = heroku_pipeline.dandi_pipeline.id
  stage    = "production"
}

# TODO: these are the old staging resources that we are moving to sandbox.
# They will be removed once the sandbox is fully operational and the staging
# resources are no longer needed.
resource "heroku_domain" "staging_old" {
  app_id   = module.api_sandbox.heroku_app_id
  hostname = "https://api-dandi-sandbox.emberarchive.org"
}
moved {
  from = module.api_staging.module.heroku.heroku_domain.heroku
  to   = heroku_domain.staging_old
}
resource "aws_route53_record" "staging_old" {
  zone_id = "Z02063701JNV8GCOUJIZZ"
  name    = "api-staging"
  type    = "CNAME"
  ttl     = "300"
  records = ["tropical-jaguar-onayajsev8r1nuze664ms6jb.herokudns.com"]
}
moved {
  from = module.api_staging.aws_route53_record.heroku
  to   = aws_route53_record.staging_old
}
