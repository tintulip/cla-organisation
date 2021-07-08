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

## Multiple Region Support

By default, GuardDuty is only enabled for the region selected. In this case, GuardDuty is manually enabled for all opted-in regions, Guard duty cannot be enabled for opted out regions. This had to be done manually in terraform as there is no [terraform](https://github.com/hashicorp/terraform/issues/24476) endpoint to make the code more dynamic.
                                                               
In each directory, the `main.tf` file references the respective `guardduty` module multiple times for every region that needs to be enabled. The region aliases are placed in the `provider.tf` file.

An example of `provider.tf` contents:
```terraform
provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}
```

and the corresponding usage within `main.tf` with modules:
```terraform
module "eu-west-2" {
  source           = "./path/to/module"
  providers = {
    aws = aws.eu-west-2
  }
}

module "eu-west-1" {
  source           = "./path/to/module"
  providers = {
    aws = aws.eu-west-1
  }
}
```