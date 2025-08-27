resource "aws_route53_zone" "dandi" {
  name = "emberarchive.org"
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "_2ab953c925117985ed729c889a811e82"
  type    = "CNAME"
  ttl     = "300"
  records = ["_369acdcce1e63f94431388fcc713b029.zfyfvmchrl.acm-validations.aws."]
}

resource "aws_route53_record" "gui" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "dandi" # apex
  type    = "A"
  ttl     = "300"
  records = ["75.2.60.5"] # Netlify's load balancer, which will proxy to our app
}
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["gui-dandiarchive-org.netlify.app."]
}

# This resource block and the next are using GitHub's custom domain
# redirection.
resource "aws_route53_record" "about" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "about"
  type    = "CNAME"
  ttl     = "300"
  records = ["dandi.github.io."]
}

resource "aws_route53_record" "docs" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "docs"
  type    = "CNAME"
  ttl     = "300"
  records = ["dandi.github.io."]
}

resource "aws_route53_record" "status" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "status"
  type    = "CNAME"
  ttl     = "300"
  records = ["dandi.github.io."]
}

resource "aws_route53_record" "email" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "" # apex
  type    = "MX"
  ttl     = "300"
  records = [
    "10 mx1.improvmx.com.",
    "20 mx2.improvmx.com.",
  ]
}

resource "aws_route53_record" "email-spf" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "" # apex
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:spf.improvmx.com ~all",
    # "google-site-verification=PRleUQ6hPcZFE9qVEQ0koOrCWMNwnMHz7QXWV5UDpFU",
  ]
}

# resource "aws_route53_record" "bluesky" {
#   zone_id = aws_route53_zone.dandi.zone_id
#   name    = "_atproto.dandiarchive.org"
#   type    = "TXT"
#   ttl     = "300"
#   records = ["did=did:plc:5tjxaioq3ynbbynnarq5dziq"]
# }

