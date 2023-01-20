---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# External object storage

GitLab relies on object storage for highly-available persistent data in Kubernetes.
By default, an S3-compatible storage solution named `minio` is deployed with the
chart, but for production quality deployments, we recommend using a hosted
object storage solution like Google Cloud Storage or AWS S3.

To disable MinIO, set this option and then follow the related documentation below:

```shell
--set global.minio.enabled=false
```

An [example of the full configuration](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/values-external-objectstorage.yaml)
has been provided in the [examples](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples).

This documentation specifies usage of access and secret keys for AWS. It is also possible to use [IAM roles](aws-iam-roles.md).

## S3 encryption

> [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2251) in GitLab 13.4.

GitLab supports [Amazon KMS](https://aws.amazon.com/kms/)
to [encrypt data stored in S3 buckets](https://docs.gitlab.com/ee/administration/object_storage.html#encrypted-s3-buckets).
You can enable this in two ways:

- In AWS, [configure the S3 bucket to use default encryption](https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html).
- In GitLab, enable [server side encryption headers](../../charts/globals.md#storage_options).

These two options are not mutually exclusive. If you choose the first option, you do not need to do
the other option, unless you want to [set an S3 bucket policy to require encrypted objects](https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-store-kms-encrypted-objects/).
You can set a default encryption policy but also enable server-side encryption headers to override those defaults.

See the [GitLab documentation on encrypted S3 buckets](https://docs.gitlab.com/ee/administration/object_storage.html#encrypted-s3-buckets)
for more details.

## Azure Blob Storage

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/25877) in GitLab 13.4.

Direct support for Azure Blob storage is available for
[uploaded attachments, CI job artifacts, LFS, and other object types supported via the consolidated settings](https://docs.gitlab.com/ee/administration/object_storage.html#storage-specific-configuration). In previous GitLab versions, an [Azure MinIO gateway](azure-minio-gateway.md) was needed.

The Azure MinIO gateway is still needed for backups. Follow [this issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2298)
for more details.

NOTE:
GitLab [does not support](https://github.com/minio/minio/issues/9978) the Azure MinIO gateway as the storage for the Docker Registry.
Please refer to the [corresponding Azure example](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.azure.yaml) when [setting up the Docker Registry](#docker-registry-images).

Although Azure uses the word container to denote a collection of blobs,
GitLab standardizes on the term bucket.

Azure Blob storage requires the use of the [consolidated object storage
settings](../../charts/globals.md#consolidated-object-storage). A
single Azure storage account name and key must be used across multiple
Azure blob containers. Customizing individual `connection` settings by
object type (for example, `artifacts`, `uploads`, and so on) is not permitted.

To enable Azure Blob storage, see
[`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azurerm.yaml)
as an example to define the Azure `connection`. You can load this as a
secret via:

```shell
kubectl create secret generic gitlab-rails-storage --from-file=connection=rails.azurerm.yml
```

Then, disable MinIO and set these global settings:

```shell
--set global.minio.enabled=false
--set global.appConfig.object_store.enabled=true
--set global.appConfig.object_store.connection.secret=gitlab-rails-storage
```

Be sure to create Azure containers for the [default names or set the container names in the bucket configuration](../../charts/globals.md#specify-buckets).

## Docker Registry images

Configuration of object storage for the `registry` chart is done via the `registry.storage` key, and the `global.registry.bucket` key.

```shell
--set registry.storage.secret=registry-storage
--set registry.storage.key=config
--set global.registry.bucket=bucket-name
```

> **Note**: The bucket name needs to be set both in the secret, and in `global.registry.bucket`. The secret is used in the registry server, and
the global is used by GitLab backups.

Create the secret per [registry chart documentation on storage](../../charts/registry/index.md#storage), then configure the chart to make use of this secret.

Examples for [S3](https://docs.docker.com/registry/storage-drivers/s3/)(S3 compatible storages, but Azure MinIO gateway not supported, see [Azure Blob Storage](#azure-blob-storage)), [Azure](https://docs.docker.com/registry/storage-drivers/azure/) and [GCS](https://docs.docker.com/registry/storage-drivers/gcs/) drivers can be found in
[`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage).

- [`registry.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.s3.yaml)
- [`registry.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.gcs.yaml)
- [`registry.azure.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.azure.yaml)

### Registry configuration

1. Decide on which storage service to use.
1. Copy appropriate file to `registry-storage.yaml`.
1. Edit with the correct values for the environment.
1. Follow [registry chart documentation on storage](../../charts/registry/index.md#storage) for creating the secret.
1. Configure the chart as documented.

## LFS, Artifacts, Uploads, Packages, External Diffs, Pseudonymizer, Terraform State, Dependency Proxy

Configuration of object storage for LFS, artifacts, uploads, packages, external
diffs, and pseudonymizer is done via the `global.appConfig.lfs`,
`global.appConfig.artifacts`, `global.appConfig.uploads`,
`global.appConfig.packages`, `global.appConfig.externalDiffs`,
`global.appConfig.dependencyProxy` and `global.appConfig.pseudonymizer` keys.

```shell
--set global.appConfig.lfs.bucket=gitlab-lfs-storage
--set global.appConfig.lfs.connection.secret=object-storage
--set global.appConfig.lfs.connection.key=connection

--set global.appConfig.artifacts.bucket=gitlab-artifacts-storage
--set global.appConfig.artifacts.connection.secret=object-storage
--set global.appConfig.artifacts.connection.key=connection

--set global.appConfig.uploads.bucket=gitlab-uploads-storage
--set global.appConfig.uploads.connection.secret=object-storage
--set global.appConfig.uploads.connection.key=connection

--set global.appConfig.packages.bucket=gitlab-packages-storage
--set global.appConfig.packages.connection.secret=object-storage
--set global.appConfig.packages.connection.key=connection

--set global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage
--set global.appConfig.externalDiffs.connection.secret=object-storage
--set global.appConfig.externalDiffs.connection.key=connection

--set global.appConfig.terraformState.bucket=gitlab-terraform-state
--set global.appConfig.terraformState.connection.secret=object-storage
--set global.appConfig.terraformState.connection.key=connection

--set global.appConfig.pseudonymizer.bucket=gitlab-pseudonymizer-storage
--set global.appConfig.pseudonymizer.connection.secret=object-storage
--set global.appConfig.pseudonymizer.connection.key=connection

--set global.appConfig.dependencyProxy.bucket=gitlab-dependencyproxy-storage
--set global.appConfig.dependencyProxy.connection.secret=object-storage
--set global.appConfig.dependencyProxy.connection.key=connection
```

Notes:

- Currently a different bucket is needed for each, otherwise performing a restore from backup will not properly function.
- Storing MR diffs on external storage is not enabled by default. So,
  for the object storage settings for `externalDiffs` to take effect,
  `global.appConfig.externalDiffs.enabled` key should have a `true` value.
- The dependency proxy feature is not enabled by default. So,
  for the object storage settings for `dependencyProxy` to take effect,
  `global.appConfig.dependencyProxy.enabled` key should have a `true` value.

See the [charts/globals documentation on appConfig](../../charts/globals.md#configure-appconfig-settings) for full details.

Create the secret(s) per the [connection details documentation](../../charts/globals.md#connection), and then configure the chart to use the provided secrets. Note, the same secret can be used for all of them.

Examples for [AWS](https://fog.io/storage/#using-amazon-s3-and-fog) (any S3 compatible like [Azure using MinIO](azure-minio-gateway.md)) and [Google](https://fog.io/storage/#google-cloud-storage) providers can be found in
[`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage).

- [`rails.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.s3.yaml)
- [`rails.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.gcs.yaml)
- [`rails.azure.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azure.yaml)
- [`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azurerm.yaml)

### appConfig configuration

1. Decide on which storage service to use.
1. Copy appropriate file to `rails.yaml`.
1. Edit with the correct values for the environment.
1. Follow [connection details documentation](../../charts/globals.md#connection) for creating the secret.
1. Configure the chart as documented.

## Backups

Backups are also stored in object storage, and need to be configured to point
externally rather than the included MinIO service. The backup/restore procedure makes
use of two separate buckets. A bucket for storing backups (`global.appConfig.backups.bucket`)
and a temporary bucket for preserving existing data during the restore process (`global.appConfig.backups.tmpBucket`).
Currently AWS S3-compatible object storage systems and Google Cloud Storage are supported backends
The backend type is configurable by setting `global.appConfig.backups.objectStorage.backend` to `s3` and `gcs` respectively.
A connection configuration through the `gitlab.toolbox.backups.objectStorage.config` key must also be provided.
When using Google Cloud Storage, the GCP project must be set with the `global.appConfig.backups.objectStorage.config.gcpProject` value.

For S3-compatible storage:

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```

For Google Cloud Storage (GCS):

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.backend=gcs
--set gitlab.toolbox.backups.objectStorage.config.gcpProject=my-gcp-project-id
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```

See the [backup/restore object storage documentation](../../backup-restore/index.md#object-storage) for full details.

NOTE:
To backup or restore files from the other object storage locations, the configuration file needs to be
configured to authenticate as a user with sufficient access to read/write to all GitLab buckets.

### Backups storage example

1. Create the `storage.config` file:

   - On Amazon S3, the contents should be in the [s3cmd configuration file format](https://s3tools.org/kb/item14.htm)

     ```ini
     [default]
     access_key = BOGUS_ACCESS_KEY
     secret_key = BOGUS_SECRET_KEY
     bucket_location = us-east-1
     multipart_chunk_size_mb = 128 # default is 15 (MB)
     ```

   - On Google Cloud Storage, you can create the file by creating a service account
     with the storage.admin role and then
     [creating a service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys).
     Below is an example of using the `gcloud` CLI to create the file.

     ```shell
     export PROJECT_ID=$(gcloud config get-value project)
     gcloud iam service-accounts create gitlab-gcs --display-name "Gitlab Cloud Storage"
     gcloud projects add-iam-policy-binding --role roles/storage.admin ${PROJECT_ID} --member=serviceAccount:gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com
     gcloud iam service-accounts keys create --iam-account gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com storage.config
     ```

   - On Azure Storage

     ```ini
     [default]
     # Setup endpoint: hostname of the Web App
     host_base = https://your_minio_setup.azurewebsites.net
     host_bucket = https://your_minio_setup.azurewebsites.net
     # Leave as default
     bucket_location = us-west-1
     use_https = True
     multipart_chunk_size_mb = 128 # default is 15 (MB)

     # Setup access keys
     # Access Key = Azure Storage Account name
     access_key = BOGUS_ACCOUNT_NAME
     # Secret Key = Azure Storage Account Key
     secret_key = BOGUS_KEY

     # Use S3 v4 signature APIs
     signature_v2 = False
     ```

1. Create the secret

   ```shell
   kubectl create secret generic storage-config --from-file=config=storage.config
   ```
