---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Migrate from the Linux package to the Helm chart **(FREE SELF)**

This guide will help you migrate from a package-based GitLab installation to
the Helm chart.

## Prerequisites

Before the migration, a few prerequisites must be met:

- The package-based GitLab instance must be up and running. Run `gitlab-ctl status`
  and confirm no services report a `down` state.
- It is a good practice to
  [verify the integrity](https://docs.gitlab.com/ee/administration/raketasks/check.html)
  of Git repositories prior to the migration.
- A Helm charts based deployment running the same GitLab version as the
  package-based installation is required.
- You need to set up the object storage which the Helm chart based deployment
  will use. For production use, we recommend you use an [external object storage](../../advanced/external-object-storage/index.md)
  and have the login credentials to access it ready. If you are using the built-in
  MinIO service, [read the docs](minio.md) on how to grab the login credentials
  from it.

## Migration steps

WARNING:
JUnit test report artifact (`junit.xml.gz`) migration
[was not supported until GitLab 12.8](https://gitlab.com/gitlab-org/gitlab/-/issues/27698#note_317190991)
by the `gitlab:artifacts:migrate` script below.

1. Migrate any existing files (uploads, artifacts, LFS objects) from the package-based
   installation to object storage:

   1. Modify `/etc/gitlab/gitlab.rb` file and configure object storage for:
      - [Uploads](https://docs.gitlab.com/ee/administration/uploads.html#s3-compatible-connection-settings)
      - [Artifacts](https://docs.gitlab.com/ee/administration/job_artifacts.html#s3-compatible-connection-settings)
      - [LFS](https://docs.gitlab.com/ee/administration/lfs/index.html#s3-for-omnibus-installations)
      - [Packages](https://docs.gitlab.com/ee/administration/packages/#using-object-storage)

      This **must** be the same object storage service that the Helm charts based deployment is
      connected to.

   1. Run reconfigure to apply the changes:

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   1. Migrate existing artifacts to object storage:

      ```shell
      sudo gitlab-rake gitlab:artifacts:migrate
      ```

   1. Migrate existing LFS objects to object storage:

      ```shell
      sudo gitlab-rake gitlab:lfs:migrate
      ```

   1. Migrate existing Packages to object storage:

      ```shell
      gitlab-rake gitlab:packages:migrate
      ```

   1. Migrate existing uploads to object storage:

      ```shell
      sudo gitlab-rake gitlab:uploads:migrate:all
      ```

      See [documentation](https://docs.gitlab.com/ee/administration/raketasks/uploads/migrate.html#migrate-to-object-storage).

   1. Visit the package-based GitLab instance and make sure the
      uploads are available. For example check if user, group and project
      avatars are rendered fine, image and other files added to issues load
      correctly, etc.

1. [Create a backup tarball](https://docs.gitlab.com/ee/raketasks/backup_restore.html#creating-a-backup-of-the-gitlab-system) and exclude the already migrated uploads:

   ```shell
   sudo gitlab-rake gitlab:backup:create SKIP=artifacts,lfs,uploads
   ```

   The backup file will be stored under `/var/opt/gitlab/backups`, unless you
   [explicitly changed](https://docs.gitlab.com/omnibus/settings/backups.html#manually-manage-backup-directory)
   it.

1. [Restore from the package-based installation](../../backup-restore/restore.md)
   to the Helm chart, starting with the secrets. You will need to migrate the
   values of `/etc/gitlab/gitlab-secrets.json` to the YAML file that will be
   used by Helm.
1. Restart all pods to make sure changes are applied:

   ```shell
   kubectl delete pods -lrelease=<helm release name>
   ```

1. Visit the Helm-based deployment and confirm projects, groups, users, issues
   etc. that existed in the package-based installation are restored.
   Also, verify if the uploaded files (avatars, files uploaded to issues, etc.)
   are loaded fine.
