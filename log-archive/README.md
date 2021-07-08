# log-archive

Creates a S3 bucket in the log-archive account containing replicated logs from the production logs bucket. This account is dedicated to collecting all logs centrally and allow administrators and auditors to review events that have occured.

## log-replication role

To allow replication of logs, a role (created in the workload account) with cross-account abilities is required. This role is [granted the ability to replicate objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/setting-repl-config-perm-overview.html#setting-repl-config-same-acctowner) from the source bucket into the destination bucket. To do this, a [bucket policy is attached to the destination bucket granting the role permissions to replicate objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/setting-repl-config-perm-overview.html#setting-repl-config-crossacct).

The ownership of the object can also be overidden to be the destination bucket owner. The log-replication role in the source account needs [permission to change object ownership](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-change-owner.html#repl-ownership-add-role-permission) and the [destination bucket policy grants the source account permission to change object ownership](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-change-owner.html#repl-ownership-accept-ownership-b-policy).

## Replication of encrypted objects

As the source account bucket uses the S3 log delivery service, it will not have access to the KMS key in the target bucket and therefore the server-side encryption in the source bucket must be `AES256`.

Objects in the destination bucket however can be encrypted by an AWS KMS customer master key and this is specified as the `replica_kms_key_id`. The replication role requires [permissions to use the AWS KMS key](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-config-for-kms-objects.html#replication-kms-extra-permissions). Additionally, the CMK key policy must [grant the source account permissions to use the key](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-config-for-kms-objects.html#replication-kms-cross-acct-scenario).

## Usage

```bash
terraform init
AWS_PROFILE=<logs admin profile> terraform plan
AWS_PROFILE=<logs admin profile> terraform apply
```

## Testing

```bash
terraform validate
tfsec .
checkov -d .
```