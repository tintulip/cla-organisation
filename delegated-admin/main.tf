module "eu-west-2" {
  source = "./guardduty"
  providers = {
    aws = aws.eu-west-2
  }
}

module "eu-west-1" {
  source = "./guardduty"
  providers = {
    aws = aws.eu-west-1
  }
}