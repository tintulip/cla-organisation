data "aws_guardduty_detector" "audit_detector_enabled_by_delegation" {
}

resource "aws_guardduty_organization_configuration" "cla_guard_duty_org" {
  auto_enable = true
  detector_id = data.aws_guardduty_detector.audit_detector_enabled_by_delegation.id
}

