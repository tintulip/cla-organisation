provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1"
}

terraform {
  backend "s3" {
    bucket = "tfstate-048191938814-sso"
    key    = "cla/sso.tfstate"
    region = "eu-west-2"
  }
}

module "state_bucket" {
  source      = "../components/terraform-state-bucket"
  bucket_name = "sso"
}

data "aws_ssoadmin_instances" "control_tower" {}

data "aws_organizations_organization" "cla" {}

locals {
  accounts = {
    production    = "073232250817"
    preproduction = "961889248176"
    builder       = "620540024451"
    sandbox       = "183042814065"
  }
}

data "aws_identitystore_group" "dali" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.control_tower.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "DaliAdmins"
  }
}

data "aws_ssoadmin_permission_set" "control_tower_readonly" {
  instance_arn = tolist(data.aws_ssoadmin_instances.control_tower.arns)[0]
  name         = "AWSReadOnlyAccess"
}

data "aws_ssoadmin_permission_set" "control_tower_admin" {
  instance_arn = tolist(data.aws_ssoadmin_instances.control_tower.arns)[0]
  name         = "AWSAdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "dali_readonly" {
  for_each           = toset([local.accounts.preproduction, local.accounts.production, local.accounts.builder, local.accounts.sandbox])
  instance_arn       = data.aws_ssoadmin_permission_set.control_tower_readonly.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.control_tower_readonly.arn

  principal_id   = data.aws_identitystore_group.dali.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "dali_admin" {
  instance_arn       = data.aws_ssoadmin_permission_set.control_tower_admin.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.control_tower_admin.arn

  principal_id   = data.aws_identitystore_group.dali.group_id
  principal_type = "GROUP"

  target_id   = local.accounts.sandbox
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_group" "delivery_teams" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.control_tower.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "DeliveryTeams"
  }
}

resource "aws_ssoadmin_permission_set" "delivery_pipelines_readonly" {
  instance_arn = tolist(data.aws_ssoadmin_instances.control_tower.arns)[0]
  name         = "DeliveryPipelinesReadOnly"
  description  = "For delivery teams needing to see what fails and how in delivery pipelines."
}

resource "aws_ssoadmin_managed_policy_attachment" "delivery_pipelines_policies" {
  for_each           = toset(["arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSCodeBuildReadOnlyAccess"])
  instance_arn       = aws_ssoadmin_permission_set.delivery_pipelines_readonly.instance_arn
  managed_policy_arn = each.key
  permission_set_arn = aws_ssoadmin_permission_set.delivery_pipelines_readonly.arn
}

resource "aws_ssoadmin_account_assignment" "delivery_teams_builder" {
  instance_arn       = aws_ssoadmin_permission_set.delivery_pipelines_readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.delivery_pipelines_readonly.arn

  principal_id   = data.aws_identitystore_group.delivery_teams.group_id
  principal_type = "GROUP"

  target_id   = local.accounts.builder
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "devops_readonly" {
  instance_arn = tolist(data.aws_ssoadmin_instances.control_tower.arns)[0]
  name         = "DevOpsReadOnly"
  description  = "For delivery teams to view the logs and metrics of services they develop and operate."
}

resource "aws_ssoadmin_managed_policy_attachment" "devops_readonly_policies" {
  for_each           = toset(["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"])
  instance_arn       = aws_ssoadmin_permission_set.devops_readonly.instance_arn
  managed_policy_arn = each.key
  permission_set_arn = aws_ssoadmin_permission_set.devops_readonly.arn
}

resource "aws_ssoadmin_account_assignment" "devops_readonly" {
  for_each           = toset([local.accounts.preproduction, local.accounts.production, local.accounts.sandbox])
  instance_arn       = aws_ssoadmin_permission_set.devops_readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.devops_readonly.arn

  principal_id   = data.aws_identitystore_group.delivery_teams.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_group" "governance" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.control_tower.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "GovernanceAdmins"
  }
}

resource "aws_ssoadmin_account_assignment" "governance_admin" {
  for_each           = toset(data.aws_organizations_organization.cla.accounts[*].id)
  instance_arn       = data.aws_ssoadmin_permission_set.control_tower_admin.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.control_tower_admin.arn

  principal_id   = data.aws_identitystore_group.governance.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

data "aws_identitystore_group" "security_auditors" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.control_tower.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = "SecurityAuditors"
  }
}

resource "aws_ssoadmin_permission_set" "security_audit" {
  instance_arn = tolist(data.aws_ssoadmin_instances.control_tower.arns)[0]
  name         = "SecurityAudit"
  description  = "To run security audits e.g. ScoutSuite"
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit_policies" {
  for_each           = toset(["arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/ReadOnlyAccess"])
  instance_arn       = aws_ssoadmin_permission_set.security_audit.instance_arn
  managed_policy_arn = each.key
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
}

resource "aws_ssoadmin_account_assignment" "security_audit" {
  for_each           = toset(data.aws_organizations_organization.cla.accounts[*].id)
  instance_arn       = aws_ssoadmin_permission_set.security_audit.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn

  principal_id   = data.aws_identitystore_group.security_auditors.group_id
  principal_type = "GROUP"

  target_id   = each.key
  target_type = "AWS_ACCOUNT"
}

