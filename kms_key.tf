resource "aws_kms_key" "s3" {
  description             = "KMS key for log archive"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/s3/log-archive"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_grant" "s3_grant" {
  name              = "s3-log-grant"
  key_id            = aws_kms_key.s3.key_id
  grantee_principal = local.replication_role
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey","ReEncryptTo","ReEncryptFrom", "DescribeKey","GenerateDataKeyWithoutPlaintext","GenerateDataKeyPair","GenerateDataKeyPairWithoutPlaintext"]

}

resource "aws_kms_grant" "s3_grant_web" {
  name              = "s3-log-grant-web"
  key_id            = aws_kms_key.s3.key_id
  grantee_principal = local.website_infra_role
  operations        = ["DescribeKey"]
}




