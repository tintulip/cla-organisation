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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"

      }
    }
  }
}
resource "aws_s3_bucket_policy" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  policy = data.aws_iam_policy_document.cla_app_logs_role_policy.json
}

data "aws_iam_policy_document" "cla_app_logs_role_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::073232250817:role/log-replication"]
    }

    resources = ["${aws_s3_bucket.app_logs.arn}/*", aws_s3_bucket.app_logs.arn]


  }
}





