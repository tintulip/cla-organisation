resource "aws_kms_key" "s3" {
  description             = "KMS key for log archive"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/s3/log-archive"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_grant" "s3_grant" {
  name              = "s3-log-grant"
  key_id            = aws_kms_key.s3.key_id
  grantee_principal = local.replication_role
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "ReEncryptTo", "ReEncryptFrom", "DescribeKey", "GenerateDataKeyWithoutPlaintext", "GenerateDataKeyPair", "GenerateDataKeyPairWithoutPlaintext"]

}

resource "aws_kms_grant" "s3_grant_web" {
  name              = "s3-log-grant-web"
  key_id            = aws_kms_key.s3.key_id
  grantee_principal = local.website_infra_role
  operations        = ["DescribeKey"]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms" {
  # requires allowing current AWS account IAM entity
  #checkov:skip=CKV_AWS_109:Allows principals to describe any key
  #checkov:skip=CKV_AWS_111:Allows write access for any user in the current AWS account
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [local.website_infra_role]
    }
    actions = [
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [local.replication_role]
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:Encrypt"
    ]
    resources = ["*"]
  }
}


