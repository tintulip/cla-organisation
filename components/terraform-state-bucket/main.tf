data "aws_caller_identity" "current" {}

resource "aws_kms_key" "state_bucket_key" {
  description             = "KMS key for the state bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "state_bucket_key" {
  name          = "alias/prepod_state_bucket"
  target_key_id = aws_kms_key.state_bucket_key.key_id
}

data "aws_iam_policy_document" "upload_to_bucket" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.state_bucket.arn}/*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [aws_kms_key.state_bucket_key.arn]
  }
}


resource "aws_s3_bucket" "state_bucket" {
  #checkov:skip=CKV_AWS_144:Not required to have cross region enabled
  #checkov:skip=CKV_AWS_18:currently cannot send access logs anywhere
  #checkov:skip=CKV_AWS_52:Cannot enable mfa_delete when applying with SSO
  #tfsec:ignore:AWS002
  bucket        = "tfstate-${data.aws_caller_identity.current.account_id}-${var.bucket_name}"
  force_destroy = "true"


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.state_bucket_key.arn
      }
      bucket_key_enabled = true
    }
  }

  versioning {
    enabled    = "true"
    mfa_delete = "false"
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}





