resource "aws_guardduty_detector" "cla_guard_duty" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "cla_guard_org" {
  auto_enable = true
  detector_id = aws_guardduty_detector.cla_guard_duty.id
}

resource "aws_guardduty_organization_admin_account" "example" {
  admin_account_id = var.audit_account_id
}

