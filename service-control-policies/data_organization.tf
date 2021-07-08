data "aws_organizations_organization" "root" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.root.roots[0].id
}