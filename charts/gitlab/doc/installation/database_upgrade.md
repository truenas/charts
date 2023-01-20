---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Upgrade the bundled PostgreSQL version **(FREE SELF)**

NOTE:
These steps are if you are using the bundled PostgreSQL chart (`postgresql.install` is not false), and not for external
PostgreSQL setups.

Changing to a new major version of PostgreSQL using the bundle PostgreSQL chart is done via a backup on the existing
database, then restoring to the new database.

As part of the `5.0.0` release of this chart, we upgraded the bundled PostgreSQL version from `11.9.0` to `12.7.0`. This is
not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [upgrade steps](#steps-for-upgrading-the-bundled-postgresql).

As part of the `4.0.0` release of this chart, we upgraded the bundled [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) from `7.7.0` to `8.9.4`. This is not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [upgrade steps](#steps-for-upgrading-the-bundled-postgresql).

## Steps for upgrading the bundled PostgreSQL

### Prepare the existing database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to follow these steps.
- If you have multiple charts installed in the same namespace. It may be necessary to pass the Helm
  release name to the database-upgrade script as well. Replace `bash -s STAGE` with
  `bash -s -- -r RELEASE STAGE` in the example commands provided later.
- If you installed a chart to a namespace other than your `kubectl` context's default, you must pass
  the namespace to the database-upgrade script. Replace `bash -s STAGE` with
  `bash -s -- -n NAMESPACE STAGE` in the example commands provided later. This option can be used
  along with `-r RELEASE`. You can set the context's default namespace by running
  `kubectl config set-context --current --namespace=NAMESPACE`, or using
  [`kubens` from kubectx](https://github.com/ahmetb/kubectx).

The `pre` stage will create a backup of your database using the backup-utility script in the Toolbox, which gets saved to the configured s3 bucket (MinIO by default):

```shell
# GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v5.0.0
curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s pre
```

### Delete existing PostgreSQL data

NOTE:
Since the PostgreSQL data format has changed, upgrading requires removing the existing PostgreSQL StatefulSet before
upgrading the release. The StatefulSet will be recreated in the next step.

WARNING:
Ensure that you have created a database backup in the previous step. Without a backup, GitLab data
will be lost.

```shell
kubectl delete statefulset RELEASE-NAME-postgresql
kubectl delete pvc data-RELEASE_NAME-postgresql-0
```

### Upgrade GitLab

Upgrade GitLab following our [standard procedure](upgrade.md#steps), with the following additions of:

Disable migrations using the following flag on your upgrade command:

1. `--set gitlab.migrations.enabled=false`

We will perform the migrations for the Database in a later step for the bundled PostgreSQL.

### Restore the Database

Note the following:

- You'll need to be using Bash 4.0 or above to run the script successfully as it requires the use of
  bash associative arrays.

1. Wait for the upgrade to complete for the Toolbox pod. RELEASE_NAME should be the name of the GitLab release from `helm list`

   ```shell
   kubectl rollout status -w deployment/RELEASE_NAME-toolbox
   ```

1. After the Toolbox pod is deployed successfully, run the `post` steps:

   ```shell
   # GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v5.0.0
   curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s post
   ```

   This step will do the following:

   1. Set replicas to 0 for the `webservice`, `sidekiq`, and `gitlab-exporter` deployments. This will prevent any other application from altering the database while the backup is being restored.
   1. Restore the database from the backup created in the pre stage.
   1. Run database migrations for the new version.
   1. Resume the deployments from the first step.

### Troubleshooting database upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```
