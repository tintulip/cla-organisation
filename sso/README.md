# AWS SSO

this terraform stack contains the configurations needed to manage AWS SSO in the management account

## Manual steps

Creation of groups in AWS SSO IdentityStore is not supported via CLI or TF.
To set up the CLA's environment you will need to add the following 4 groups manually:

- `DaliAdmins`
  - description: `For the Platform team`
  - why we have this: For a platform team to do their job. Allows some degree of power user access, but not unrestricted admin to organisational root accounts.
- `DeliveryTeams`
  - description: `For Web and Webapp teams to view their pipelines & operational status of things they deploy`
  - why we have this: as per description.
- `SecurityAuditors`
  - description: `This is our security audit group (for the red team)`
  - why we have this: to allow both red and blue teams to run tooling like ScoutSuite. In a real scenario, this would be used for similar purposes for a SecOps/SOC team, plus granting access to security tooling in the Security Audit account.
- `GovernanceAdmins`
  - description: `For sensitive operations across organisational root accounts`
  - why we have this: You could use the `AWSControlTowerAdmins` group that you get out of the box to the same effect - this exist to highlight what kind of grouping we think would be necessary to employ the segregation of permissions that we are utilising in Tin Tulip.

Note that in a real scenario these would be administered by your actual identity source e.g. Active Directory, and might be mapped to existing user groups.