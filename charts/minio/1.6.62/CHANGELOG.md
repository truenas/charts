# Change Log

This contains all the notable changes to the MinIO application.

## [1.5.0]

1. On fresh installation, minIO data directory's ownership will be updated to minio:minio.
2. For existing installations that are exhibiting the upgrade, the minIO data directory's ownership will be migrated to minio:minio.

## [1.6.2]

1. Users with existing instances are advised to not update to the newer version.
  MinIO released a major version change with no backwards compatibility.
  In order to use newer versions of MinIO, a manual migration is needed.
  For more information, visit https://min.io/docs/minio/linux/operations/install-deploy-manage/migrate-fs-gateway.html
