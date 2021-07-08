data "aws_iam_policy_document" "deny_unused_regions" {
  statement {
    sid    = "DenyAllOutsideIrelandAndLondon"
    effect = "Deny"
    not_actions = [
      "a4b:*",
      "acm:*",
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "awsbillingconsole:*",
      "budgets:*",
      "ce:*",
      "chime:*",
      "cloudfront:*",
      "config:*",
      "cur:*",
      "directconnect:*",
      "ec2:DescribeRegions",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVpnGateways",
      "fms:*",
      "globalaccelerator:*",
      "health:*",
      "iam:*",
      "importexport:*",
      "kms:*",
      "mobileanalytics:*",
      "networkmanager:*",
      "organizations:*",
      "pricing:*",
      "route53:*",
      "route53domains:*",
      "s3:GetAccountPublic*",
      "s3:ListAllMyBuckets",
      "s3:ListBuckets",
      "s3:PutAccountPublic*",
      "shield:*",
      "guardduty:DescribeOrganizationConfiguration",
      "guardduty:ListFindings",
      "guardduty:ListDetectors",
      "guardduty:ListMembers",
      "guardduty:ListOrganizationAdminAccounts",
      "guardduty:ListPublishingDestinations",
      "guardduty:ListFilters",
      "guardduty:ListInvitations",
      "guardduty:GetDetector",
      "guardduty:GetFilter",
      "guardduty:GetFindings",
      "guardduty:GetFindingsStatistics",
      "guardduty:GetInvitationsCount",
      "guardduty:GetMasterAccount",
      "guardduty:GetMemberDetectors",
      "guardduty:GetMembers",
      "guardduty:GetThreatIntelSet",
      "guardduty:GetUsageStatistics",
      "securityhub:*",
      "sts:*",
      "support:*",
      "trustedadvisor:*",
      "waf-regional:*",
      "waf:*",
      "wafv2:*",
      "sns:ListTopics",
      "wellarchitected:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["eu-west-1", "eu-west-2"]
    }
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalARN"
      values = [
        "arn:aws:iam::*:role/AWSControlTowerAdmin",
        "arn:aws:iam::*:role/AWSControlTowerCloudTrailRole",
        "arn:aws:iam::*:role/AWSControlTowerStackSetRole",
        "arn:aws:iam::*:role/*ControlTower*",
        "arn:aws:iam::*:role/*controltower*"
      ]
    }
  }
  statement {
    sid    = "ViewConsole"
    effect = "Allow"
    actions = [
      "aws-portal:ViewAccount",
      "account:ListRegions"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DisableOptInRegions"
    effect = "Deny"
    actions = [
      "account:EnableRegion",
      "account:DisableRegion"
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_unused_regions" {
  name        = "Disable unused regions"
  description = "Disable unused regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_unused_regions.json
}

resource "aws_organizations_policy_attachment" "deny_unused_regions_attachment" {
  policy_id = aws_organizations_policy.deny_unused_regions.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}
