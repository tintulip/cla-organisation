provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      "team"       = "platform"
      "managed_by" = "terraform"
      "tf:stack"   = "aws-scps"
    }
  }
}