---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Upgrade Guide **(FREE SELF)**

Before upgrading your GitLab installation, you need to check the
[changelog](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md)
corresponding to the specific release you want to upgrade to and look for any
[release notes](../releases/index.md) that might pertain to the new GitLab chart
version.

NOTE:
**Zero-downtime upgrades** are not available with the GitLab charts.
Ongoing work to support this feature can be tracked via
[the GitLab Operator issue](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/issues/59).

WARNING:
If you are upgrading from the `4.x` version of the chart to the latest `5.0` release, you need
to first update to the latest `4.12.x` patch release in order for the upgrade to work.
The [5.0 release notes](../releases/5_0.md) describe the supported upgrade path.

WARNING:
If you are upgrading from the `3.x` version of the chart to the latest `4.0` release, you need
to first update to the latest `3.3.x` patch release in order for the upgrade to work.
The [4.0 release notes](../releases/4_0.md) describe the supported upgrade path.

We also recommend that you take a [backup](../backup-restore/index.md) first. Also note that you
must provide all values using `helm upgrade --set key=value` syntax or `-f values.yaml` instead of
using `--reuse-values`, because some of the current values might be deprecated.

You can retrieve your previous `--set` arguments cleanly, with
`helm get values <release name>`. If you direct this into a file
(`helm get values <release name> > gitlab.yaml`), you can safely pass this
file via `-f`. Thus `helm upgrade gitlab gitlab/gitlab -f gitlab.yaml`.
This safely replaces the behavior of `--reuse-values`

Mappings between chart versioning and GitLab versioning can be found [here](../index.md#gitlab-version-mappings).

## Steps

NOTE:
If you're upgrading to the `5.0` version of the chart, follow the [manual upgrade steps for 5.0](#upgrade-steps-for-50-release).
If you're upgrading to the `4.0` version of the chart, follow the [manual upgrade steps for 4.0](#upgrade-steps-for-40-release).
If you're upgrading to an older version of the chart, follow the [upgrade steps for older versions](upgrade_old.md).

Before you upgrade, reflect on your set values and if you've possibly "over-configured" your settings. We expect you to maintain a small list of modified values, and leverage most of the chart defaults. If you've explicitly set a large number of settings by:

- Copying computed settings
- Copying all settings and explicitly defining values that are actually the same as the default values

This will almost certainly cause issues during the upgrade as the configuration structure could have changed across versions, and that will cause problems applying the settings. We cover how to check this in the following steps.

The following are the steps to upgrade GitLab to a newer version:

1. Check the [change log](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md) for the specific version you would like to upgrade to.
1. Go through the [deployment documentation](deployment.md) step by step.
1. Extract your previously provided values:

   ```shell
   helm get values gitlab > gitlab.yaml
   ```

1. Decide on all the values you need to carry through as you upgrade. GitLab has reasonable default values, and while upgrading, you can attempt to pass in all values from the above command, but it could create a scenario where a configuration has changed across chart versions and it might not map cleanly. We advise keeping a minimal set of values that you want to explicitly set, and passing those during the upgrade process.
1. Perform the upgrade, with values extracted in the previous step:

   ```shell
   helm upgrade gitlab gitlab/gitlab \
     --version <new version> \
     -f gitlab.yaml \
     --set gitlab.migrations.enabled=true \
     --set ...
   ```

During a major database upgrade, we ask you to set `gitlab.migrations.enabled` set to `false`.
Ensure that you explicitly set it back to `true` for future updates.

## Upgrade the bundled PostgreSQL to version 12

NOTE:
If you aren't using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need to
perform this step.

Upgrading to PostgreSQL 12 for GitLab 14.x is required. PostgreSQL 12 is supported by GitLab 13.4 and later. [PostgreSQL 12 brings significant performance improvements](https://www.postgresql.org/about/news/postgresql-12-released-1976/).

To upgrade the bundled PostgreSQL to version 12, the following steps are required:

1. [Prepare the existing database](database_upgrade.md#prepare-the-existing-database).
1. [Delete existing PostgreSQL data](database_upgrade.md#delete-existing-postgresql-data).
1. Update the `postgresql.image.tag` value to `12.4.0` and [reinstall the chart](database_upgrade.md#upgrade-gitlab) to create a new PostgreSQL 12 database.
1. [Restore the database](database_upgrade.md#restore-the-database).

## Upgrade the bundled PostgreSQL chart

As part of the `5.0.0` release of this chart, we upgraded the bundled PostgreSQL version from `11.9.0` to `12.7.0`. This is
 not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [5.0 upgrade steps](#upgrade-steps-for-50-release).

As part of the `4.0.0` release of this chart, we upgraded the bundled [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) from `7.7.0` to `8.9.4`. This is not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [4.0 upgrade steps](#upgrade-steps-for-40-release).

## Upgrade steps for 5.5 release

The `task-runner` chart [was renamed](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/2099/diffs)
to `toolbox` and removed in `5.5.0`. As a result, any mention of `task-runner`
in your configuration should be renamed to `toolbox`. In version 5.5 and newer,
use the `toolbox` chart, and in version 5.4 and older, use the `task-runner` chart.

### Missing object storage secret error

Upgrading to 5.5 or newer might cause an error similar to the following:

```shell
Error: UPGRADE FAILED: execution error at (gitlab/charts/gitlab/charts/toolbox/templates/deployment.yaml:227:23): A valid backups.objectStorage.config.secret is needed!
```

If the secret mentioned in the error already exists and is correct, then this error
is likely because there is an object storage configuration value that still references
`task-runner` instead of the new `toolbox`. Rename `task-runner` to `toolbox` in your
configuration to fix this.

There is an [open issue about clarifying the error message](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3004).

## Upgrade steps for 5.0 release

The `5.0.0` release requires manual steps in order to perform the upgrade. If you're using the
bundled PostgreSQL, the best way to perform this upgrade is to back up your old database, and
restore into a new database instance.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you are using an external PostgreSQL database, you should first upgrade the database to version 12 or greater. Then
follow the [normal upgrade steps](#steps).

If you are using the bundled PostgreSQL database, you should follow the [bundled database upgrade steps](database_upgrade.md#steps-for-upgrading-the-bundled-postgresql).

### Troubleshooting 5.0 release upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

## Upgrade steps for 4.0 release

The `4.0.0` release requires manual steps in order to perform the upgrade. If you're using the
bundled PostgreSQL, the best way to perform this upgrade is to back up your old database, and
restore into a new database instance.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you are using an external PostgreSQL database, you should first upgrade the database to version 11 or greater. Then
follow the [normal upgrade steps](#steps).

If you are using the bundled PostgreSQL database, you should follow the [bundled database upgrade steps](database_upgrade.md#steps-for-upgrading-the-bundled-postgresql).

### Troubleshooting 4.0 release upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

#### 4.8: Repository data appears to be lost upgrading Praefect

The Praefect chart is not yet considered suitable for production use.

If you have enabled Praefect before upgrading to version 4.8 of the chart (GitLab 13.8),
note that the StatefulSet name for Gitaly will now include the virtual storage name.

In version 4.8 of the Praefect chart, the ability to specify multiple virtual storages
was added, making it necessary to change the StatefulSet name.

Any existing Praefect-managed Gitaly StatefulSet names (and, therefore, their
associated PersistentVolumeClaims) will change as well, leading to repository data
appearing to be lost.

Prior to upgrading, ensure that:

- All your repositories are in sync across the Gitaly Cluster, and GitLab
is not in use during the upgrade. To check whether the repositories are in sync,
run the following command in one of your Praefect pods:

  ```shell
  /usr/local/bin/praefect -config /etc/gitaly/config.toml dataloss
  ```

- You have a complete and tested backup.

Repository data can be restored by following the
[managing persistent volumes documentation](../advanced/persistent-volumes/),
which provides guidance on reconnecting existing PersistentVolumeClaims to previous
PersistentVolumes.

A key step of the process is setting the old persistent volumes' `persistentVolumeReclaimPolicy`
to `Retain`. If this step is missed, actual data loss will likely occur.

After reviewing the documentation, there is a scripted summary of the procedure
[in a comment on one of a related issues](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2532#note_506467539).

Having reconnected the PersistentVolumes, it is likely that all your repositories
will be set `read-only` by Praefect, as shown by running the following in a
Praefect container:

```plaintext
praefect -config /etc/gitaly/config.toml dataloss
```

If all your Git repositories are in sync across the old persistent volumes, use the
`accept-dataloss` procedure for each repository to fix the Gitaly Cluster in Praefect.

[We have an issue open](https://gitlab.com/gitlab-org/gitaly/-/issues/3448) to verify
that this is the best approach to fixing Praefect.
