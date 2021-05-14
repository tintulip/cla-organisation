data "aws_iam_policy_document" "deny_iam_console_login" {
  statement {
    sid = "DenyConsoleLogin"
    actions = [
      "iam:CreateLoginProfile",
      "iam:UpdateLoginProfile"
    ]
    resources = [
      "*"
    ]
    effect = "Deny"
  }
}

resource "aws_organizations_policy" "deny_iam_console_login" {
  name        = "Deny IAM users from logging into the console"
  description = "Prevents IAM users from logging into the console"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_iam_console_login.json
}

resource "aws_organizations_policy_attachment" "deny_iam_console_login_attachment" {
  policy_id = aws_organizations_policy.deny_iam_console_login.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}