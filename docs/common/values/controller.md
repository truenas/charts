# Controller

## Key: controller

Info:

- Type: `dict`
- Default:

  ```yaml
    controller:
      # -- Enable the controller.
      enabled: true
      # -- Set the controller type.
      # Valid options are Deployment | DaemonSet | StatefulSet | CronJob | Job
      type: Deployment
      # -- Set labels on the Deployment/StatefulSet/DaemonSet/CronJob/Job.
      labels: {}
      # -- Set annotations on the Deployment/StatefulSet/DaemonSet.
      annotations: {}
      # -- Revision history limit
      revisionHistoryLimit: 3
      # -- Number of desired pods
      replicas: 1
      # -- Set the controller upgrade strategy
      # For Deployments, valid values are Recreate (default) and RollingUpdate.
      # For StatefulSets, valid values are OnDelete and RollingUpdate (default).
      # For DaemonSets, valid values are OnDelete and RollingUpdate (default).
      # Jobs and CronJobs, ignores this
      strategy: ""
      # -- Set rollingUpdate strategies
      rollingUpdate:
        # -- Set RollingUpdate max unavailable
        # Deployments | DaemonSet | StatefulSet
        unavailable:
        # -- Set RollingUpdate max surge
        # Deployments | DaemonSet
        surge:
        # -- Set RollingUpdate partition
        # StatefulSet
        partition:
  ```

- Helm Template:
  - controller.labels.KEY: ❌
  - controller.labels.VALUE: ✅
  - controller.annotations.KEY: ❌
  - controller.annotations.VALUE: ✅

Can be defined in:

- `.Values`.controller

---

Defines options for the controller (Deployment, StatefulSet, etc)

In `Deployments` it should not need anything to be defined at all in the Chart.

> When running a standalone `Job` or `CronJob`, values that you would
> define in `.Values.jobs.[job-name].VALUE`, would go in `.Values.controller`.
>
> Eg. values like `schedule` `restartPolicy`.
