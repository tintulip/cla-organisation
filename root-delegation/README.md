# root-delegation

This particular directory allows delegation of the account that will become the GuardDuty Organization Admin Account. The AWS account that utilizes the resources within this directory must be the an Organizations primary account (root account).

## Inputs

The only input required is the `admin_account_id` which typically is the `Audit Account`. The `audit_account_id` variable can be modified in [terraform.tfvars](./terraform.tfvars).

## Usage

```bash
AWS_REGION=<anyregion> AWS_PROFILE=<root admin account> terraform apply
```

### Required Privileges

The following policy is required to enable GuardDuty delegated admin.

```json
{
    "Sid": "Permissions to Enable GuardDuty delegated administrator",
    "Effect": "Allow",
    "Action": [
        "guardduty:EnableOrganizationAdminAccount",
        "organizations:EnableAWSServiceAccess",
        "organizations:RegisterDelegatedAdministrator",
        "organizations:ListDelegatedAdministrators",
        "organizations:ListAWSServiceAccessForOrganization",
        "organizations:DescribeOrganizationalUnit",
        "organizations:DescribeAccount",
        "organizations:DescribeOrganization"
    ],
    "Resource": "*"
}
```

## Security Testing

```bash
terraform validate
tfsec .
checkov -d .
```