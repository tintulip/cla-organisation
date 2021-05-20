resource "aws_s3_bucket" "app_logs" {
  #tfsec:ignore:AWS002
  #checkov:skip=CKV_AWS_144:Not required to have cross region enabled
  #checkov:skip=CKV_AWS_145:Cannot use KMS with CF distributions
  #checkov:skip=CKV_AWS_18:Access logging needs to go into a cross account bucket
  #checkov:skip=CKV_AWS_52:Can not have mfa delete enabled only root can

  bucket = "cla-app-logs"
  acl    = "private"

  tags = {
    Name        = "cla-app-logs"
    Environment = "cla"
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log-archive"
    enabled = true

    tags = {
      rule      = "log-archive"
      autoclean = "true"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

}

resource "aws_s3_bucket_policy" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id
  policy = data.aws_iam_policy_document.cla_app_logs_role_policy.json
}

data "aws_iam_policy_document" "cla_app_logs_role_policy" {
  statement {
    actions = [
      "s3:List*",
      "s3:GetBucketLocation",
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::073232250817:role/log-replication"]
    }

    resources = ["${aws_s3_bucket.app_logs.arn}/*", aws_s3_bucket.app_logs.arn]


  }
}





