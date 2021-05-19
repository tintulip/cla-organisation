data "aws_guardduty_detector" "audit_detector_enabled_by_delegation" {
}

resource "aws_guardduty_organization_configuration" "cla_guard_duty_org" {
  auto_enable = true
  detector_id = data.aws_guardduty_detector.audit_detector_enabled_by_delegation.id
}

resource "aws_guardduty_member" "root" {
  account_id  = "048191938814"
  detector_id = data.aws_guardduty_detector.audit_detector_enabled_by_delegation.id
  email       = "james.gumbley@cabinetoffice.gov.uk"
  invite      = false
}
resource "aws_guardduty_member" "log_archive" {
  account_id  = "689141309029"
  detector_id = data.aws_guardduty_detector.audit_detector_enabled_by_delegation.id
  email       = "fmeden+tintulip+awslogs@thoughtworks.com"
  invite      = false
}

resource "aws_cloudwatch_event_rule" "guard_duty_findings" {
  name        = "capture-guard-duty-findings"
  description = "Captures GuardDuty findings"

  event_pattern = <<EOF
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
EOF
}

# created by ControlTower
data "aws_sns_topic" "aggregated_security_notifications" {
  name = "aws-controltower-AggregateSecurityNotifications"
}

resource "aws_cloudwatch_event_target" "guard_duty_to_aggregated_security" {
  rule      = aws_cloudwatch_event_rule.guard_duty_findings.name
  target_id = "SendToSNS"
  arn       = data.aws_sns_topic.aggregated_security_notifications.arn
}
