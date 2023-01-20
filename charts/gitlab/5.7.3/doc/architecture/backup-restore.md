---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Backup and restore

This document explains the technical implementation of the backup and restore into/from CNG.

## Toolbox pod

The [toolbox chart](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/toolbox) deploys a pod into the cluster. This pod will act as an entry point for interaction with other containers in the cluster.

Using this pod user can run commands using `kubectl exec -it <pod name> -- <arbitrary command>`

The Toolbox runs a container from the [Toolbox image](https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-toolbox).

The image contains some custom scripts that are to be called as commands by the user, these scripts can be found [here](https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-toolbox/scripts). These scripts are for running Rake tasks, backup, restore, and some helper scripts for interacting with object storage.

## Backup utility

[Backup utility](https://gitlab.com/gitlab-org/build/CNG/blob/master/gitlab-toolbox/scripts/bin/backup-utility) is one of the scripts
in the toolbox container and as the name suggests it is a script used for doing backups but also handles restoring of an existing backup.

### Backups

The backup utility script when run without any arguments creates a backup tar and uploads it to object storage.

#### Sequence of execution

Backups are made using the following steps, in order:

1. Backup the database (if not skipped) using the [GitLab backup Rake task](https://gitlab.com/gitlab-org/build/CNG/blob/74dc35d4b481e86330bf6b244f88e5dd8876cc0c/gitlab-toolbox/scripts/bin/backup-utility#L120)
1. Backup the repositories (if not skipped) using the [GitLab backup Rake task](https://gitlab.com/gitlab-org/build/CNG/blob/74dc35d4b481e86330bf6b244f88e5dd8876cc0c/gitlab-toolbox/scripts/bin/backup-utility#L123)
1. For each of the object storage backends
   1. If the object storage backend is marked for skipping, skip this storage backend.
   1. Tar the existing data in the corresponding object storage bucket naming it `<bucket-name>.tar`
   1. Move the tar to the backup location on disk
1. Write a `backup_information.yml` file which contains some metadata identifying the version of GitLab, the time of the backup and the skipped items.
1. Create a tar file containing individual tar files along with `backup_information.yml`
1. Upload the resulting tar file to object storage `gitlab-backups` bucket.

#### Command line arguments

- `--skip <component>`

  You can skip parts of the backup process by using `--skip <component>` for every component that you want to skip in the backup process. Skippable components are the database (`db`), repositories (`repositories`), and any of the object storages (`registry`, `uploads`, `artifacts`, `lfs`, `packages`, `external_diffs`, or `terraform_state`).

- `-t <timestamp-override-value>`

  This gives you partial control over the name of the backup: when you specify this flag the created backup will be named `<timestamp-override-value>_gitlab_backup.tar`. The default value is the current UNIX timestamp, postfixed with the current date formatted to `YYYY_mm_dd`.

- `--backend <backend>`

  Configures the object storage backend to use for backups. Can be either `s3` or `gcs`. Default is `s3`.

- `--storage-class <storage-class-name>`

  It is also possible to specify the storage class in which the backup is stored using `--storage-class <storage-class-name>`, allowing you to save on backup storage costs. If unspecified, this will use the default of the storage backend.

  NOTE:
  This storage class name is passed through as-is to the storage class argument of your specified backend.

#### GitLab backup bucket

The default name of the bucket that will be used to store backups is `gitlab-backups`. This is configurable
using the `BACKUP_BUCKET_NAME` environment variable.

#### Backing up to Google Cloud Storage

By default, the backup utility uses `s3cmd` to upload and download artifacts from object storage. While this can work with Google Cloud Storage (GCS),
it requires using the Interoperability API which makes undesirable compromises to authentication and authorization. When using Google Cloud Storage
for backups you can configure the backup utility script to use the Cloud Storage native CLI, `gsutil`, to do the upload and download
of your artifacts by setting the `BACKUP_BACKEND` environment variable to `gcs`.

### Restore

The backup utility when given an argument `--restore` attempts to restore from an existing backup to the running instance. This
backup can be from either an Omnibus GitLab or a CNG Helm chart installation given that both the instance that was
backed up and the running instance runs the same version of GitLab. The restore expects a file in backup bucket using `-t <backup-name>` or a remote URL using `-f <url>`.

When given a `-t` parameter it looks into backup bucket in object storage for a backup tar with such name. When
given a `-f` parameter it expects that the given URL is a valid URI of a backup tar in a location accessible from the container.

After fetching the backup tar the sequence of execution is:

1. For repositories and database run the [GitLab backup Rake task](https://gitlab.com/gitlab-org/gitlab-foss/tree/master/lib/tasks/gitlab/backup.rake)
1. For each of object storage backends:
   - tar the existing data in the corresponding object storage bucket naming it `<backup-name>.tar`
   - upload it to `tmp` bucket in object storage
   - clean up the corresponding bucket
   - restore the backup content into the corresponding bucket

NOTE:
If the restore fails, the user will need to revert to previous backup using data in `tmp` directory of the backup bucket. This is currently a manual process.
