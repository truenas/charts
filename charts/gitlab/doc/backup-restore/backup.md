---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Backing up a GitLab installation **(FREE SELF)**

GitLab backups are taken by running the `backup-utility` command in the Toolbox pod provided in the chart. Backups can also be automated by enabling the [Cron based backup](#cron-based-backup) functionality of this chart.

Before running the backup for the first time, you should ensure the
[Toolbox is properly configured](../charts/gitlab/toolbox/index.md#configuration)
for access to [object storage](index.md#object-storage)

Follow these steps for backing up a GitLab Helm chart based installation

## Create the backup

1. Ensure the toolbox pod is running, by executing the following command

   ```shell
   kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
   ```

1. Run the backup utility

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility
   ```

1. Visit the `gitlab-backups` bucket in the object storage service and ensure a tarball has been added. It will be named in `<timestamp>_<version>_gitlab_backup.tar` format.

1. This tarball is required for restoration.

## Cron based backup

NOTE:
The Kubernetes CronJob created by the Helm Chart
sets the `cluster-autoscaler.kubernetes.io/safe-to-evict: "false"`
annotation on the jobTemplate. Some Kubernetes environments, such as
GKE Autopilot, don't allow this annotation to be set and will not create
Job Pods for the backup.

Cron based backups can be enabled in this chart to happen at regular intervals as defined by the [Kubernetes schedule](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#schedule).

You need to set the following parameters:

- `gitlab.toolbox.backups.cron.enabled`: Set to true to enable cron based backups
- `gitlab.toolbox.backups.cron.schedule`: Set as per the Kubernetes schedule docs
- `gitlab.toolbox.backups.cron.extraArgs`: Optionally set extra arguments for [backup-utility](https://gitlab.com/gitlab-org/build/CNG/blob/master/gitlab-toolbox/scripts/bin/backup-utility) (like `--skip db`)

## Backup utility extra arguments

The backup utility can take some extra arguments. See what those are with:

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --help
```

## Backup the secrets

You should also save a copy of the rails secrets. (These are not included in the backup as a security precaution. We recommend keeping your full backup that includes the database separate from the copy of the secrets.)

1. Find the object name for the rails secrets

   ```shell
   kubectl get secrets | grep rails-secret
   ```

1. Save a copy of the rails secrets

   ```shell
   kubectl get secrets <rails-secret-name> -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > secrets.yaml
   ```

1. Store `secrets.yml` in a secure location, you may need it to fully restore your backups.

## Additional Information

- [GitLab Chart Backup/Restore Introduction](index.md)
- [Restoring a GitLab installation](restore.md)
