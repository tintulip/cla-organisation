# delegated-admin

This directory manages the GuardDuty Organization Configuration and the AWS account that utilizes the resource must be assigned as a delegated Organization adminstator account. As the [root-delegation](../root-delegation) assigns the delegated Organization Admin account as the `Audit Account`, this directory must be executed within the `audit account` profile. The delegated admin can then enable and manage GuardDuty for other AWS accounts within the Organization.

## Inputs

Assuming that the steps within this repository are executed after setting up `AWS Control Tower`, there are two additional accounts that need to be added as members which are already part of the organization (`root` and `log archive`). Future accounts that are created will automatically have `AWS GuardDuty` enabled.

Within [guard_duty.tf](./guard_duty.tf), there is a resource ([aws_guardduty_member](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_member)) which requires inputs to identify those accounts such as `aws_account_id` and `email`.

## Considerations

Using the [guardduty_organization_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) `auto_enable` argument does not automatically enable `S3 Protection` for all accounts. This is due to [the terraform code](https://github.com/hashicorp/terraform-provider-aws/blob/main/aws/resource_aws_guardduty_organization_configuration.go#L24) not passing the parameters required for `S3 protection` despite the [AWS API](https://docs.aws.amazon.com/guardduty/latest/APIReference/API_UpdateOrganizationConfiguration.html#API_UpdateOrganizationConfiguration_RequestSyntax) supporting it. The only option is to manually enable through the AWS CLI.

## Usage

```bash
AWS_PROFILE=<audit admin account> terraform apply

# Get detector ID
AWS_PROFILE=<audit admin account> aws guardduty list-detectors

# enable S3 Logs autoEnable
AWS_PROFILE=<audit admin account> aws guardduty update-organization-configuration --detector-id <detecter-id> --auto-enable --data-sources S3Logs={AutoEnable=true}
```