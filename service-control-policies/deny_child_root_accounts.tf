data "aws_iam_policy_document" "deny_services_for_child_root_accounts" {
  statement {
    sid = "DenyRootUser"
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
    effect = "Deny"
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
  statement {
    effect = "Deny"
    actions = [
      "organizations:LeaveOrganization"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_organizations_policy" "deny_services_for_child_root_accounts" {
  name        = "Deny services for child root accounts"
  description = "Prevents the root user from being used in child accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_services_for_child_root_accounts.json
}

resource "aws_organizations_policy_attachment" "deny_services_for_root_attachment" {
  policy_id = aws_organizations_policy.deny_services_for_child_root_accounts.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}