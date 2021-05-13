module "eu-west-2" {
  source           = "./guardduty"
  audit_account_id = var.audit_account_id
  providers = {
    aws = aws.eu-west-2
  }
}

module "eu-west-1" {
  source           = "./guardduty"
  audit_account_id = var.audit_account_id
  providers = {
    aws = aws.eu-west-1
  }
}