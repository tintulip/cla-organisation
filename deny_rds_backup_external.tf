locals {
  workloads_id = element([for x in data.aws_organizations_organizational_units.ou.children : x.id if x.name == "Workloads_Prod"], 0)
}

data "aws_iam_policy_document" "deny_rds_backup_external" {
  statement {
    sid    = "DenyExternalRdsBackup"
    effect = "Deny"
    actions = [
      "rds:CopyDBSnapshot",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:DescribeDBSnapshot",
      "rds:DescribeEvents",
      "rds:ModifyDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:StartExportTask",
      "rds:CancelExportTask",
      "rds:DescribeExportTasks",
      "rds:RestoreDBInstanceFromDBSnapshot",
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
  policy_id = aws_organizations_policy.deny_rds_backup_external.id
  target_id = local.workloads_id
}