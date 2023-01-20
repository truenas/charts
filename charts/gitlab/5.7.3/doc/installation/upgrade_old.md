---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Upgrade old versions **(FREE SELF)**

If you are looking to upgrade a recent version of the Chart, see the [regular Upgrade Guide](upgrade.md).

Upgrade instructions for older versions are available on this page.

## Upgrade steps for 3.0 release

The `3.0.0` release requires manual steps in order to perform the upgrade.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you're using the bundled PostgreSQL, the best way to perform this upgrade is to backup your old
database, and restore into a new database instance. We've automated some of the steps, as an
alternative, you can perform the steps manually.

### Prepare the existing database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
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
# GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v3.0.0
curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s pre
```

### Prepare the cluster database secrets

> **NOTICE:** If you are not using the bundled PostgreSQL chart (`postgresql.install` is false):
>
> - If you have supplied `global.psql.password.key`, you do not need to perform this step.
> - If you have supplied `global.psql.password.secret`, additionally set `global.psql.password.key` to the name of your existing key to bypass this step.

The secret key for the application database key is changing from `postgres-password`, to `postgresql-password`. Use one of the two steps described below to update your database password secret:

1. If you'd like to use an auto-generated PostgreSQL password, delete the existing secret to allow the upgrade to generate a new password for you. RELEASE-NAME should be the name of the GitLab release from `helm list`:

   ```shell
   # Create a local copy of the old secret in case we need to restore the old database
   kubectl get secret RELEASE-NAME-postgresql-password -o yaml > postgresql-password.backup.yaml
   # Delete the secret so a new one can be created
   kubectl delete secret RELEASE-NAME-postgresql-password
   ```

1. If you want to use the same password, edit the secret, and change the key from `postgres-password` to `postgresql-password`. Additionally, we need a secret for the superuser account. Add a key for that user `postgresql-postgres-password`:

   ```shell
   # Encode the superuser password into base64
   echo SUPERUSER_PASSWORD | base64
   kubectl edit secret RELEASE-NAME-postgresql-password
   # Make the appropriate changes in your EDITOR window
   ```

### Delete existing services

The `3.0` release updates an immutable field in the NGINX Ingress, this requires us to first delete all the services
before upgrading. You can see more details in our troubleshooting documentation, under [Immutable Field Error, spec.clusterIP](../troubleshooting/index.md#specclusterip).

1. Remove all affected services. RELEASE_NAME should be the name of the GitLab release from `helm list`:

   ```shell
   kubectl delete services -lrelease=RELEASE_NAME
   ```

WARNING:
This will change any dynamic value for the `LoadBalancer` for NGINX Ingress from this chart, if in use. See
[global Ingress settings documentation](../charts/globals.md#configure-ingress-settings) for more details regarding
`externalIP`. You may be required to update DNS records!

### Upgrade GitLab

Upgrade GitLab following our [standard procedure](upgrade.md#steps), with the following additions of:

If you are using the bundled PostgreSQL, disable migrations using the following flag on your upgrade command:

1. `--set gitlab.migrations.enabled=false`

We will perform the migrations for the Database in a later step for the bundled PostgreSQL.

### Restore the Database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
- You'll need to be using Bash 4.0 or above to run the script successfully as it requires the use of
  bash associative arrays.

1. Wait for the upgrade to complete for the Toolbox pod. RELEASE_NAME should be the name of the GitLab release from `helm list`

   ```shell
   kubectl rollout status -w deployment/RELEASE_NAME-toolbox
   ```

1. After the Toolbox pod is deployed successfully, run the `post` steps:

   This step will do the following:

   1. Set replicas to 0 for the `webservice`, `sidekiq`, and `gitlab-exporter` deployments. This will prevent any other application from altering the database while the backup is being restored.
   1. Restore the database from the backup created in the pre stage.
   1. Run database migrations for the new version.
   1. Resume the deployments from the first step.

   ```shell
   # GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v3.0.0
   curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s post
   ```

### Troubleshooting 3.0 release upgrade process

- Make sure that you are using Helm 2.14.3 or >= 2.16.1 [due to the bug in 2.15.x](../releases/3_0.md#problematic-helm-215).
- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

- You may face the error below when running `helm upgrade`:

  ```plaintext
  Error: kind ConfigMap with the name "gitlab-gitlab-shell-sshd" already exists in the cluster and wasn't defined in the previous release.
  Before upgrading, please either delete the resource from the cluster or remove it from the chart
  Error: UPGRADE FAILED: kind ConfigMap with the name "gitlab-gitlab-shell-sshd" already exists in the cluster and wasn't defined in the previous release.
  Before upgrading, please either delete the resource from the cluster or remove it from the chart
  ```

  The error message can also mention other configmaps like `gitlab-redis-health`, `gitlab-redis-headless`, etc.
  To fix it, make sure that the services were removed as mentioned in the [upgrade steps for 3.0 release](#delete-existing-services).
  After that, also delete the configmaps shown in the error message with: `kubectl delete configmap <configmap-name>`.
