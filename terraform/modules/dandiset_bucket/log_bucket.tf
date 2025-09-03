data "aws_canonical_user_id" "log_bucket_owner_account" {}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "dandiset_log_bucket_policy" {
  statement {
    sid       = "S3ServerAccessLogsPolicy"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.log_bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.dandiset_bucket.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }

  # APL ITSD Managed policy
  statement {
    sid = "AllowSSLRequestsOnly"

    resources = [
      "${aws_s3_bucket.log_bucket.arn}",
      "${aws_s3_bucket.log_bucket.arn}/*",
    ]

    actions = [
      "s3:*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}

resource "aws_s3_bucket_policy" "dandiset_log_bucket_policy" {
  provider = aws

  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.dandiset_log_bucket_policy.json
}

data "aws_iam_policy_document" "dandiset_log_bucket_owner" {
  version = "2008-10-17"

  // TODO: gate behind a "cross account" flag, since this is technically only
  // needed for sponsored log bucket.
  statement {
    resources = [
      "${aws_s3_bucket.log_bucket.arn}",
      "${aws_s3_bucket.log_bucket.arn}/*",
    ]

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
  }
}

resource "aws_iam_user_policy" "dandiset_log_bucket_owner" {
  // The Heroku IAM user will always be in the project account
  provider = aws.project

  name = "${var.log_bucket_name}-ownership-policy"
  user = var.heroku_user.name

  policy = data.aws_iam_policy_document.dandiset_log_bucket_owner.json
}
