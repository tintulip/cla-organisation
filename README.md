# service-control-policies

Contains Service Control Policies (SCPs) which are used to define maximum available permissions for AWS accounts within an AWS Organization.

## Context

Service Control Policies (SCPs) help to [manage permissions in an organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) by offering central control over available permissions for all accounts. They are JSON policies similar to IAM but instead of granting permissions, they specify the maximum permissions or can mandate conditional requirements to perform specific actions.

## SCPs

### Deny access to services for root in child accounts

This policy, found in [deny_child_root_accounts.tf](./deny_child_root_accounts.tf), prevents root users from being used in any account aside from the Control Management account.

### Deny IAM users logging through the console

This policy removes the ability for an IAM user to create a password and therefore be able to login through the IAM console. It can be found in [deny_console_logins.tf](./deny_console_logins.tf). Any situation which requires the use of logging in through the console can be done through logging in via SSO. This is to prevent risks from weak passwords.

### Disable all regions except London and Ireland

This policy disables AWS regions we don't use so that we can't have bad things happening in regions where we might overlook. The regions added after 2019 are disabled by [default](https://docs.aws.amazon.com/general/latest/gr/rande-manage.html). A further constraint has been added to prevent users from enabling these regions. It can be found in [deny_unused_regions.tf](./deny_unused_regions.tf). The template used to write this policy is available [here](https://controltower.aws-management.tools/security/restrict_regions/).

### Availability trade-off

Resilience from a regional failure is not prioritised over data location. The preferred data location is London then Ireland, therefore the CLA is restricted to these regions.

## Usage

```bash
terraform init
AWS_PROFILE=<root admin profile> terraform plan
AWS_PROFILE=<root admin profile> terraform apply
```

### Required Permissions

The minimum permissions required to create, update or delete policies and to attach a SCP to an organization unit:

```json
{
    "Sid": "Permissions to manage SCPs",
    "Effect": "Allow",
    "Action": [
        "organizations:CreatePolicy",
        "organizations:UpdatePolicy",
        "organizations:DescribePolicy",
        "organizations:DescribeOrganization",
        "organizations:DescribePolicy",
        "organizations:TagResource",
        "organizations:UntagResource",
        "organizations:DeletePolicy",
        "organizations:AttachPolicy",
        "organizations:DetachPolicy"
    ],
    "Resource": "*"
}
```

### Deleting SCPs

Before deleting a policy, it must first be detached from all attached entities.

## Testing

```bash
terraform validate
tfsec .
checkov -d .
```
