resource "aws_guardduty_detector" "detector" {
  enable = true
}

resource "aws_guardduty_organization_admin_account" "root_delegates_to_audit" {
  admin_account_id = var.audit_account_id
}

