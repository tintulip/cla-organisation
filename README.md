# enable-scps

Contains Service Control Policies (SCPs) which are used to define maximum available permissions for AWS accounts within an AWS Organization.

## Context

Service Control Policies (SCPs) help to [manage permissions in an organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) by offering central control over available permissions for all accounts. They are JSON policies similar to IAM but instead of granting permissions, they specify the maximum permissions or can mandate conditional requirements to perform specific actions.

## SCPs

### Deny access to services for root in child accounts

This policy, found in [deny_child_root_accounts.tf](./deny_child_root_accounts.tf), prevents root users from being used in any account aside from the Control Management account.

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