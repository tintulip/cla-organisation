# enable-guardduty

Enables AWS GuardDuty for all AWS accounts within an organization managed by the Audit account.

## Assumptions

This repository assumes that [AWS Control Tower](https://aws.amazon.com/controltower/) has been implemented and that there exists an `Audit Account` within the `Security OU`. The `root account` refers to the `AWS Control Tower Management Account`.

## Context

When [GuardDuty is used with an AWS Organization](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html), any account can be designated as the GuardDuty administrator account. It is not recommended for the Organization root account to be set as the delegated administrator, yet the delegated administrator must be set by the Organization root account.

As Control Tower has recently been set up, the organization currently contains 3 accounts:
- the management account (organization root)
- audit account
- log archive

It is recommended that the `audit account` becomes the GuardDuty delegated administrator account and that the other two accounts plus any future accounts have GuardDuty enabled.

## Steps

1. The first step requires the management account to designate a delegated GuardDuty administrator. This is done within the [root-delegation](./root-delegation) directory.

2. Once the account is delegated as the GuardDuty administrator, it will have GuardDuty automatically enabled and is granted permission to enable and manage GuardDuty for all accounts in the organization. The [delegated-admin](./delegated-admin) directory will configure GuardDuty to ensure that all future accounts have GuardDuty automatically enabled as well as invite the remaining two accounts within the organization to enable GuardDuty.

3. As S3 Logs are not currently automatically enabled with Terraform, a [further call to the AWS CLI](./delegated-admin#considerations) can be executed to ensure S3 protection.