resource "aws_route53_zone" "dandi_sandbox" {
  name = "sandbox.dandiarchive.org"
}

# Point the top-level zone at the sandbox zone
resource "aws_route53_record" "ns_sandbox" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "sandbox"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dandi_sandbox.name_servers
}

# TODO: remove these once we don't need the redirects anymore.
resource "aws_route53_record" "gui-staging" {
  # Intentionally pointing to the production zone
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "gui-staging"
  type    = "CNAME"
  ttl     = "300"
  records = ["gui-staging-dandiarchive-org.netlify.com"]
}
resource "aws_route53_record" "api-staging" {
  # Intentionally pointing to the production zone
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "api-staging"
  type    = "CNAME"
  ttl     = "300"
  records = ["api-staging-dandiarchive-org.netlify.com"]
}

resource "aws_route53_record" "gui_sandbox" {
  zone_id = aws_route53_zone.dandi_sandbox.zone_id
  name    = "" # apex
  type    = "A"
  ttl     = "300"
  records = ["75.2.60.5"] # Netlify's load balancer, which will proxy to our app
}
