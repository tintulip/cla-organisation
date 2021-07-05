locals {
  workloads_id = [for x in data.aws_organizations_organizational_units.ou.children : x.id if x.name == "Workloads_Prod"]
}



data "aws_iam_policy_document" "deny_rds_backup_external" {
  statement {
    sid    = "DenyExternalRdsBackup"
    effect = "Deny"
    actions = [
      "rds:CopyDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:StartExportTask",
      "rds:ShareDBSnapshot"
    ]
    resources = [
      "*"
    ]

  }
}


resource "aws_organizations_policy" "deny_rds_backup_external" {
  name        = "Deny external rds backup"
  description = "Deny external rds backup"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_rds_backup_external.json
}

resource "aws_organizations_policy_attachment" "unit" {
  for_each = toset(local.workloads_id)
  policy_id = aws_organizations_policy.deny_rds_backup_external.id
  target_id = each.key
}